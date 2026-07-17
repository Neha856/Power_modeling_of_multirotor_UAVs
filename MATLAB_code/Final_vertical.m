% === Load Filtered CSV Data ===
data = readtable('vertical_ascent_filtered_balanced2a_1Hz.csv','VariableNamingRule','preserve');

TargetVz = data.("TargetVz(m/s)");
Power = data.("Power(W)");

%% === Step 1: Average power per TargetVz step ===
uniqueSpeeds = unique(TargetVz);
avgPower = zeros(size(uniqueSpeeds));

for i = 1:length(uniqueSpeeds)
    mask = TargetVz == uniqueSpeeds(i);
    avgPower(i) = mean(Power(mask));
end

% Representative dataset
samples = table(uniqueSpeeds, avgPower, ...
    'VariableNames', {'TargetVz(m/s)','AvgPower(W)'});

%% === Fixed constants ===
fixed_W   = 29.4;   % N (3.0 kg * 9.81)
fixed_n   = 4;      % rotor count
fixed_rho = 1.225;  % air density
fixed_A   = 0.385;  % rotor disc area

%% === Step 2: Proposed Vertical Ascent Model (Eq. 13 + Eq. 5 hover) ===
powerModelProposed = @(params, V) ...
    (params(1)*params(2)/(8*sqrt(fixed_n*fixed_rho*fixed_A))) .* (fixed_W/params(3)).^(3/2) ... % hover baseline
    + (1+params(4)) .* fixed_W.^(3/2) ./ sqrt(2*fixed_n*fixed_rho*fixed_A) ...                  % induced hover
    + 0.5*fixed_W.*V ...                                                                       % climb term
    + (fixed_n/4).*params(5).*fixed_rho.*V.^3 ...                                              % parasite term
    + (0.5*fixed_W + (fixed_n/4).*params(5).*fixed_rho.*V.^2) .* ...
    sqrt((1+params(5)/fixed_A).*V.^2 + (2*fixed_W)./(fixed_n.*fixed_rho.*fixed_A));            % induced climb

% Parameters vector: [δ, s, C_T, k, S_fp_perp]
x0_prop = [0.011, 0.045, 0.0012, 0.11, 0.02];
lb_prop = [0.005, 0.02, 0.0005, 0.05, 0];
ub_prop = [0.02, 0.08, 0.002, 0.2, 0.5];

opts = optimoptions('lsqcurvefit','Display','off');
params_fit_prop = lsqcurvefit(powerModelProposed, x0_prop, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_prop, ub_prop, opts);
P_fit_prop = powerModelProposed(params_fit_prop, samples.("TargetVz(m/s)"));

% Print fitted Proposed parameters
paramNamesProp = {'δ','s','C_T','k','S_fp_perp'};
resultsTableProp = table(paramNamesProp', params_fit_prop', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for Proposed Vertical Ascent Model ===');
disp(resultsTableProp);

%% === Step 3: APM Aerodynamic Model (Eq. 14 decomposition) ===
% Parameters: [k1, k2, c2, c4, mg, c5]
thrustAPM = @(V, params) sqrt( (params(5) - (params(6).*V.^2)).^2 + (params(4).*V.^2).^2 );

powerModelAPM = @(params, V) ...
    params(1) .* thrustAPM(V, params) .* ...
    ( V/2 + sqrt((V/2).^2 + thrustAPM(V, params)./(params(2).^2)) ) ... % induced term
    + params(3) .* (thrustAPM(V, params).^(3/2)) ...                    % profile term
    + params(4) .* V.^3;                                                % parasite term

x0_apm = [0.85, sqrt(2*fixed_rho*fixed_A), 0.3, 0.03, fixed_W, 0.028];
lb_apm = [0.5, 0.1, 0.1, 0.01, fixed_W, 0.01];
ub_apm = [1.0, 2, 1, 0.1, fixed_W, 0.05];

params_fit_apm = lsqcurvefit(@(p,V) powerModelAPM(p,V), x0_apm, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_apm, ub_apm, opts);
P_fit_apm = powerModelAPM(params_fit_apm, samples.("TargetVz(m/s)"));

% Print fitted APM parameters
paramNamesAPM = {'k1','k2','c2','c4','mg','c5'};
resultsTableAPM = table(paramNamesAPM', params_fit_apm', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for APM Vertical Ascent Model ===');
disp(resultsTableAPM);

%% === Step 4: Average Relative Difference ===
relDiffProp = mean(abs(P_fit_prop - samples.("AvgPower(W)")) ./ samples.("AvgPower(W)")) * 100;
relDiffAPM  = mean(abs(P_fit_apm  - samples.("AvgPower(W)")) ./ samples.("AvgPower(W)")) * 100;

fprintf('Average Relative Difference (Proposed Model): %.2f %%\n', relDiffProp);
fprintf('Average Relative Difference (APM Model): %.2f %%\n', relDiffAPM);

%% === Step 5: Plot Results ===
figure;
scatter(samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), 60, 'b','filled'); hold on;
plot(samples.("TargetVz(m/s)"), P_fit_prop, 'r--','LineWidth',2);   % Proposed ascent fit
plot(samples.("TargetVz(m/s)"), P_fit_apm, 'm-.','LineWidth',2);    % APM aerodynamic fit
xlabel('Vertical Speed (m/s)');
ylabel('Average Power (W)');
title('Vertical Ascent Power Curve: Proposed vs APM');
legend('Measured Avg Samples','Proposed Ascent Model','APM Aerodynamic Model');
xlim([0 5]); ylim([0 600]); 
xticks(0:0.5:5); grid on;
