% === Load Filtered CSV Data (Descent) ===
data = readtable('vertical_descent_filtered_20tol_1Hz.csv','VariableNamingRule','preserve');

TargetVz = abs(data.("TargetVz(m/s)"));   % take absolute values for descent
Power    = data.("Power(W)");

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
fixed_W   = 29.43;   % N (3.0 kg * 9.81)
fixed_n   = 4;      % rotor count
fixed_rho = 1.225;  % air density
fixed_A   = 0.385;  % rotor disc area
fixed_k2  = sqrt(2*fixed_rho*fixed_A); % aerodynamic scaling

%% === Step 2: Proposed Vertical Descent Model (Eq. 14 with hover) ===
% Parameters vector: [δ, s, C_T, k, S_fp_perp]
powerModelProposedDesc = @(params, V) ...
    (params(1)*params(2)/(8*sqrt(fixed_n*fixed_rho*fixed_A))) .* (fixed_W/params(3)).^(3/2) ... % hover baseline
    + (1+params(4)) .* fixed_W.^(3/2) ./ sqrt(2*fixed_n*fixed_rho*fixed_A) ...                  % induced hover
    + 0.5*fixed_W.*V ...                                                                       % descent term
    - (fixed_n/4).*params(5).*fixed_rho.*V.^3 ...                                              % parasite drag (negative in descent)
    + (0.5*fixed_W - (fixed_n/4).*params(5).*fixed_rho.*V.^2) .* ...
    sqrt((1 - params(5)/fixed_A).*V.^2 + (2*fixed_W)./(fixed_n.*fixed_rho.*fixed_A));          % induced descent

x0_prop = [0.011, 0.045, 0.0012, 0.11, 0.02];
lb_prop = [0.005, 0.02, 0.0005, 0.05, 0];
ub_prop = [0.02, 0.08, 0.002, 0.2, 0.48];

opts = optimoptions('lsqcurvefit','Display','off');
params_fit_prop = lsqcurvefit(powerModelProposedDesc, x0_prop, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_prop, ub_prop, opts);
P_fit_prop = powerModelProposedDesc(params_fit_prop, samples.("TargetVz(m/s)"));

% Print fitted Proposed parameters
paramNamesProp = {'δ','s','C_T','k','S_fp_perp'};
resultsTableProp = table(paramNamesProp', params_fit_prop', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for Proposed Vertical Descent Model ===');
disp(resultsTableProp);

%% === Step 3: APM Aerodynamic Descent Model (Eq. 14, mg & k2 fixed) ===
% Parameters to fit: [k1, c2, c4, c5]
thrustAPM = @(V, params) sqrt( (fixed_W - (params(4).*V.^2)).^2 + (params(3).*V.^2).^2 );

powerModelAPMDesc = @(params, V) ...
    params(1) .* thrustAPM(V, params) .* ...
    ( V/2 + sqrt((V/2).^2 + thrustAPM(V, params)./(fixed_k2.^2)) ) ... % induced term
    + params(2) .* (thrustAPM(V, params).^(3/2)) ...                   % profile term
    - params(3) .* V.^3;                                               % parasite term (negative in descent)

x0_apm = [0.85, 0.3, 0.03, 0.028];
lb_apm = [0.5, 0.1, 0.01, 0.01];
ub_apm = [1.0, 1.0, 0.1, 0.05];

params_fit_apm = lsqcurvefit(@(p,V) powerModelAPMDesc(p,V), x0_apm, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_apm, ub_apm, opts);
P_fit_apm = powerModelAPMDesc(params_fit_apm, samples.("TargetVz(m/s)"));

% Print fitted APM parameters
paramNamesAPM = {'k1','c2','c4','c5'};
resultsTableAPM = table(paramNamesAPM', params_fit_apm', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for APM Vertical Descent Model (mg, k2 fixed) ===');
disp(resultsTableAPM);

%% === Step 4: Average Relative Difference ===
relDiffProp = mean(abs(P_fit_prop - samples.("AvgPower(W)")) ./ samples.("AvgPower(W)")) * 100;
relDiffAPM  = mean(abs(P_fit_apm  - samples.("AvgPower(W)")) ./ samples.("AvgPower(W)")) * 100;

fprintf('Average Relative Difference (Proposed Descent Model): %.2f %%\n', relDiffProp);
fprintf('Average Relative Difference (APM Descent Model, mg & k2 fixed): %.2f %%\n', relDiffAPM);

%% === Step 5: Plot Results ===
%% === Step 5a: Plot BEFORE Filtering (Raw 10 Hz Data) ===
rawData = readtable('vertical_descent_data_unequal.csv','VariableNamingRule','preserve');
figure;
scatter(abs(rawData.("TargetVz(m/s)")), rawData.("Power(W)"), 20, 'b','filled');
xlabel('Vertical Speed (m/s)');
ylabel('Power (W)');
title('Raw Data Before Filtering (10 Hz)');
xlim([0 3.5]); ylim([0 600]); xticks(0:0.5:3.5); grid on;

%% === Step 5b: Plot AFTER Filtering with Avg + Fits (1 Hz Data) ===
figure;

% Filtered data (light red plus markers) – use the actual filtered dataset
scatter(abs(data.("TargetVz(m/s)")), data.("Power(W)"), 25, '+', ...
    'MarkerEdgeColor',[1 0.6 0.6]); hold on;

% Average values (dark red filled circles)
plot(samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), 'ro', ...
    'MarkerFaceColor',[0.6 0 0], 'MarkerSize',5);

% Proposed model fit (blue solid curve)
plot(samples.("TargetVz(m/s)"), P_fit_prop, 'b-','LineWidth',2);

% APM model fit (magenta dash-dot curve)
plot(samples.("TargetVz(m/s)"), P_fit_apm, 'm-.','LineWidth',2);

xlabel('Vertical Speed (m/s)');
ylabel('Average Power (W)');
title('Filtered Data, Power-Speed Samples, and Model Fits (Vertical Descent)');
legend('Filtered Data','Power-Speed Samples','Proposed Model','APM Model');
xlim([0 3.5]); ylim([0 600]); xticks(0:0.5:3.5); grid on;
