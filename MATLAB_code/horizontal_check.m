% === Step 1: Read and Filtered Data (already saved) ===
data = readtable('horizontal_filtered_final_1Hz.csv','VariableNamingRule','preserve');

TargetVx = data.("TargetSpeed(m/s)");
Power    = data.("Power(W)");

% === Step 2: Round Target Speed to integer bins (0–10 m/s) ===
TargetVxInt = round(TargetVx);
data.TargetVxInt = TargetVxInt;

uniqueSpeeds = (0:10)';
avgPower = zeros(size(uniqueSpeeds));
for i = 1:length(uniqueSpeeds)
    mask = data.TargetVxInt == uniqueSpeeds(i);
    if any(mask)
        avgPower(i) = mean(Power(mask));
    else
        avgPower(i) = NaN;
    end
end

samples = table(uniqueSpeeds, avgPower, ...
    'VariableNames', {'TargetVx(m/s)','AvgPower(W)'});

% === Step 3: Fixed constants ===
fixed_m   = 3;                
fixed_W   = fixed_m * 9.81;   
fixed_n   = 4;                
fixed_rho = 1.225;            
fixed_A   = 0.385*4;          
fixed_k2  = sqrt(2*fixed_rho*0.385);

% === Step 4: Proposed Horizontal Flight Model (Eq. 8) ===
powerModelProposedHor = @(params, V) ...
    (params(1)*params(2)/(8*sqrt(fixed_rho*fixed_A))) .* (fixed_W/params(3)).^(3/2) ...
    + (3*params(1)*params(2)/8) .* sqrt((fixed_W*fixed_rho*fixed_A)/params(3)) .* V.^2 ...
    + (1+params(4)) .* fixed_W.^(3/2) ./ sqrt(2*fixed_rho*fixed_A) .* ...
    sqrt( sqrt(1 + (V.^4)./(4*params(6).^4)) - (V.^2)./(2*params(6).^2) ) ...
    + (fixed_n/2)*params(5).*fixed_rho.*V.^3;

x0_prop = [0.01, 0.04, 0.001, 0.1, 0.009, 5];
lb_prop = [0.005, 0.02, 0.0005, 0.05, 0, 4];
ub_prop = [0.02, 0.08, 0.002, 0.2, 0.3, 9];

opts = optimoptions('lsqcurvefit','Display','off');
validMask = ~isnan(samples.("AvgPower(W)"));
params_fit_prop = lsqcurvefit(powerModelProposedHor, x0_prop, ...
    samples.("TargetVx(m/s)")(validMask), samples.("AvgPower(W)")(validMask), ...
    lb_prop, ub_prop, opts);

P_fit_prop = powerModelProposedHor(params_fit_prop, samples.("TargetVx(m/s)"));

% === Step 5: APM Aerodynamic Horizontal Model ===
thrustAPM = @(V, params) sqrt( (fixed_W - (params(4).*V.^2)).^2 + (params(3).*V.^2).^2 );
powerModelAPMHor = @(params, V) ...
    params(1) .* thrustAPM(V, params) .* ...
    ( V/2 + sqrt((V/2).^2 + thrustAPM(V, params)./(fixed_k2.^2)) ) ...
    + params(2) .* (thrustAPM(V, params).^(3/2)) ...
    + params(3) .* V.^3;

x0_apm = [0.85, 0.3, 0.03, 0.028];
lb_apm = [0.5, 0.1, 0.01, 0.01];
ub_apm = [1.0, 1.0, 0.1, 0.05];
params_fit_apm = lsqcurvefit(@(p,V) powerModelAPMHor(p,V), x0_apm, ...
    samples.("TargetVx(m/s)")(validMask), samples.("AvgPower(W)")(validMask), ...
    lb_apm, ub_apm, opts);

P_fit_apm = powerModelAPMHor(params_fit_apm, samples.("TargetVx(m/s)"));

% === Step 6: Compute Energy per Distance (J/m) ===
EnergyPerMeter = samples.("AvgPower(W)") ./ samples.("TargetVx(m/s)");
EnergyPerMeter(samples.("TargetVx(m/s)") == 0) = NaN; % exclude hover
samples.EnergyPerMeter = EnergyPerMeter;

Epm_fit_prop = P_fit_prop ./ samples.("TargetVx(m/s)");
Epm_fit_prop(samples.("TargetVx(m/s)") == 0) = NaN;

Epm_fit_apm = P_fit_apm ./ samples.("TargetVx(m/s)");
Epm_fit_apm(samples.("TargetVx(m/s)") == 0) = NaN;

% === Step 7: Relative Differences ===
relDiffProp = mean(abs(Epm_fit_prop(validMask) - samples.EnergyPerMeter(validMask)) ...
    ./ samples.EnergyPerMeter(validMask),'omitnan') * 100;
relDiffAPM  = mean(abs(Epm_fit_apm(validMask)  - samples.EnergyPerMeter(validMask)) ...
    ./ samples.EnergyPerMeter(validMask),'omitnan') * 100;

fprintf('Average Relative Difference (Proposed Energy Model): %.2f %%\n', relDiffProp);
fprintf('Average Relative Difference (APM Energy Model): %.2f %%\n', relDiffAPM);

% === Step 8: Plot Energy Efficiency vs Speed ===
figure;
scatter(samples.("TargetVx(m/s)"), samples.EnergyPerMeter, 80, 'x', ...
    'MarkerEdgeColor',[0.6 0 0], 'LineWidth',2); hold on;
plot(samples.("TargetVx(m/s)"), Epm_fit_prop, 'b-','LineWidth',2);
plot(samples.("TargetVx(m/s)"), Epm_fit_apm, 'm-.','LineWidth',2);
xlabel('Horizontal Speed (m/s)');
ylabel('Energy per Distance (J/m)');
title('Horizontal Flight Energy Efficiency vs Speed (0–10 m/s)');
legend('Measured Avg Energy/Distance','Proposed Model','APM Model');
xlim([-1 11]); ylim([0 400]); xticks(0:1:10); grid on;
