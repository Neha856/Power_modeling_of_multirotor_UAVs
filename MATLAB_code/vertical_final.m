% === Load Filtered CSV Data ===
data = readtable('vertical_ascent_filtered_balanced2a_1Hz.csv','VariableNamingRule','preserve');

TargetVz = data.("TargetVz(m/s)");
Power = data.("Power(W)");

rho = 1.225; % air density

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

%% === Step 2: Proposed Vertical Ascent Model (Eq. 13 + Eq. 5 hover) ===
powerModelProposed = @(params, V) ...
    (params(6)*params(7)/(8*sqrt(params(2)*rho*params(5)))) .* (params(1)/params(8)).^(3/2) ... % hover baseline
    + (1+params(9)) .* params(1).^(3/2) ./ sqrt(2*params(2)*rho*params(5)) ...                  % induced hover
    + 0.5*params(1).*V ...                                                                     % climb term
    + (params(2)/4).*params(3).*rho.*V.^3 ...                                                  % parasite term
    + (0.5*params(1) + (params(2)/4).*params(3).*rho.*V.^2) .* ...
    sqrt((1+params(3)/params(5)).*V.^2 + (2*params(1))./(params(2).*rho.*params(5)));         % induced climb

% Parameters vector: [W, n, S_fp_perp, rho, A, δ, s, C_T, k]
x0_prop = [15, 4, 0.02, 1.225, 0.5, 0.011, 0.045, 0.0012, 0.11];
lb_prop = [10, 3, 0.005, 1.0, 0.1, 0.005, 0.02, 0.0005, 0.05];
ub_prop = [30, 6, 0.05, 1.3, 1.0, 0.02, 0.08, 0.002, 0.2];

opts = optimoptions('lsqcurvefit','Display','iter');
params_fit_prop = lsqcurvefit(powerModelProposed, x0_prop, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_prop, ub_prop, opts);
P_fit_prop = powerModelProposed(params_fit_prop, samples.("TargetVz(m/s)"));

% Print fitted Proposed parameters
paramNamesProp = {'W','n','S_fp_perp','rho','A','δ','s','C_T','k'};
resultsTableProp = table(paramNamesProp', params_fit_prop', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for Proposed Vertical Ascent Model ===');
disp(resultsTableProp);

%% === Step 3: APM Aerodynamic Model (Eq. 14 decomposition) ===
% Parameters: [k1, k2, c2, c4, mg, c5]
thrustAPM = @(V, params) sqrt( (params(5) - (params(6).*V.^2)).^2 + (params(4).*V.^2).^2 );

powerModelAPM = @(params, V) ...
    params(1) .* thrustAPM(V, params) .* ...
    ( V/2 + sqrt((V/2).^2 + thrustAPM(V, params)./(params(2).^2)) ) ... % induced term
    + params(3) .* (thrustAPM(V, params).^(3/2)) ...                        % profile term
    + params(4) .* V.^3;                                                    % parasite term

x0_apm = [0.85, sqrt(2*rho*0.214), 0.3, 0.03, 20, 0.028];
lb_apm = [0.5, 0.1, 0.1, 0.01, 10, 0.01];
ub_apm = [1.0, 2, 1, 0.1, 40, 0.05];

params_fit_apm = lsqcurvefit(@(p,V) powerModelAPM(p,V), x0_apm, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_apm, ub_apm, opts);
P_fit_apm = powerModelAPM(params_fit_apm, samples.("TargetVz(m/s)"));

% Print fitted APM parameters
paramNamesAPM = {'k1','k2','c2','c4','mg','c5'};
resultsTableAPM = table(paramNamesAPM', params_fit_apm', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for APM Vertical Ascent Model ===');
disp(resultsTableAPM);

%% === Step 4: Plot Results ===
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
