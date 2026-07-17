% === Load Filtered CSV Data (Vertical Ascent) ===
data = readtable('vertical_ascent_filtered_balanced2a_1Hz.csv','VariableNamingRule','preserve');

TargetVz = data.("TargetVz(m/s)");
Power    = data.("Power(W)");

%% Step 1: Average power per TargetVz step
uniqueSpeeds = unique(TargetVz);
avgPower = zeros(size(uniqueSpeeds));

for i = 1:length(uniqueSpeeds)
    mask = TargetVz == uniqueSpeeds(i);
    avgPower(i) = mean(Power(mask));
end

samples = table(uniqueSpeeds, avgPower, ...
    'VariableNames', {'TargetVz(m/s)','AvgPower(W)'});

%% Step 2: Fixed constants
fixed_W   = 29.43;   % N (3.0 kg * 9.81)
fixed_n   = 4;      % rotor count
fixed_rho = 1.225;  % air density
fixed_A   = 0.385;  % rotor disc area
fixed_k2  = sqrt(2*fixed_rho*fixed_A);

%% Step 3: Proposed Vertical Ascent Model
powerModelProposed = @(params, V) ...
    (params(1)*params(2)/(8*sqrt(fixed_n*fixed_rho*fixed_A))) .* (fixed_W/params(3)).^(3/2) ...
    + (1+params(4)) .* fixed_W.^(3/2) ./ sqrt(2*fixed_n*fixed_rho*fixed_A) ...
    + 0.5*fixed_W.*V ...
    + (fixed_n/4).*params(5).*fixed_rho.*V.^3 ...
    + (0.5*fixed_W + (fixed_n/4).*params(5).*fixed_rho.*V.^2) .* ...
    sqrt((1+params(5)/fixed_A).*V.^2 + (2*fixed_W)./(fixed_n.*fixed_rho.*fixed_A));

% Parameters vector: [δ, s, C_T, k, S_fp_perp]
x0_prop = [0.011, 0.045, 0.0012, 0.11, 0.02];
lb_prop = [0.005, 0.02, 0.0005, 0.05, 0];
ub_prop = [0.02, 0.08, 0.002, 0.2, 0.5];

opts = optimoptions('lsqcurvefit','Display','off');
params_fit_prop = lsqcurvefit(powerModelProposed, x0_prop, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_prop, ub_prop, opts);
P_fit_prop = powerModelProposed(params_fit_prop, samples.("TargetVz(m/s)"));

%% Step 4: APM Aerodynamic Ascent Model
thrustAPM = @(V, params) sqrt( (fixed_W - (params(4).*V.^2)).^2 + (params(3).*V.^2).^2 );

powerModelAPM = @(params, V) ...
    params(1) .* thrustAPM(V, params) .* ...
    ( V/2 + sqrt((V/2).^2 + thrustAPM(V, params)./(fixed_k2.^2)) ) ...
    + params(2) .* (thrustAPM(V, params).^(3/2)) ...
    + params(3) .* V.^3;

x0_apm = [0.85, 0.3, 0.03, 0.028];
lb_apm = [0.5, 0.1, 0.01, 0.01];
ub_apm = [1.0, 1.0, 0.1, 0.05];

params_fit_apm = lsqcurvefit(@(p,V) powerModelAPM(p,V), x0_apm, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), lb_apm, ub_apm, opts);
P_fit_apm = powerModelAPM(params_fit_apm, samples.("TargetVz(m/s)"));

%% Step 5: Compute Energy per Distance (J/m)
EnergyPerMeter = samples.("AvgPower(W)") ./ samples.("TargetVz(m/s)");
EnergyPerMeter(samples.("TargetVz(m/s)") == 0) = NaN; % remove hover
samples.EnergyPerMeter = EnergyPerMeter;

% Model predictions
Epm_fit_prop = P_fit_prop ./ samples.("TargetVz(m/s)");
Epm_fit_prop(samples.("TargetVz(m/s)") == 0) = NaN;

Epm_fit_apm = P_fit_apm ./ samples.("TargetVz(m/s)");
Epm_fit_apm(samples.("TargetVz(m/s)") == 0) = NaN;

%% Step 6: Relative Differences
relDiffProp = mean(abs(Epm_fit_prop - samples.EnergyPerMeter) ./ samples.EnergyPerMeter,'omitnan') * 100;
relDiffAPM  = mean(abs(Epm_fit_apm  - samples.EnergyPerMeter) ./ samples.EnergyPerMeter,'omitnan') * 100;

fprintf('Average Relative Difference (Proposed Ascent Energy Model): %.2f %%\n', relDiffProp);
fprintf('Average Relative Difference (APM Ascent Energy Model): %.2f %%\n', relDiffAPM);

%% Step 7: Plot Energy Efficiency vs Speed
figure;
scatter(samples.("TargetVz(m/s)"), samples.EnergyPerMeter, 80, 'x', 'MarkerEdgeColor',[0.6 0 0], 'LineWidth',2); hold on; % dark red wide cross
plot(samples.("TargetVz(m/s)"), Epm_fit_prop, 'b-','LineWidth',2);
plot(samples.("TargetVz(m/s)"), Epm_fit_apm, 'm-.','LineWidth',2);
xlabel('Vertical Ascent Speed (m/s)');
ylabel('Energy per Distance (J/m)');
title('Vertical Ascent Energy Efficiency vs Speed');
legend('Measured Avg Energy/Distance','Proposed Model Based','APM Model Based');
xlim([0 6]); ylim([0 800]); xticks(0:0.5:5); grid on;
