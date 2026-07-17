% === Load filtered CSV ===
data = readtable('vertical_ascent_filtered_balanced2a_1Hz.csv','VariableNamingRule','preserve');

% Group by TargetVz
uniqueSpeeds = unique(data.("TargetVz(m/s)"));
avgPower = zeros(size(uniqueSpeeds));
avgVz = zeros(size(uniqueSpeeds));

for i = 1:length(uniqueSpeeds)
    mask = data.("TargetVz(m/s)") == uniqueSpeeds(i);
    avgPower(i) = mean(data.("Power(W)")(mask));
    avgVz(i) = mean(data.("Vz(m/s)")(mask));
end

% Representative dataset
samples = table(uniqueSpeeds, avgVz, avgPower, ...
    'VariableNames', {'TargetVz(m/s)','AvgMeasuredVz(m/s)','AvgPower(W)'});

% Save one-sample-per-speed dataset
writetable(samples,'vertical_ascent_samples.csv');

%% === Plot representative curve ===
figure;
scatter(samples.("TargetVz(m/s)"), samples.("AvgPower(W)"), 60, 'r','filled');
xlabel('Target Vertical Speed (m/s)');
ylabel('Average Power (W)');
title('Representative Vertical Ascent Power vs Speed');
grid on;
xlim([0 5]);
ylim([0 600]);
xticks(0:0.5:5);

%% === Fit ascent power model with hover term from Eq.(5) ===
% Hover power model (Eq. 5 with δ and s separated):
hoverPowerFun = @(params) ...
    (params(6)*params(7)/(8*sqrt(params(2)*params(4)*params(5)))) .* (params(1)/params(8)).^(3/2) + ...
    (1+params(9)) .* params(1).^(3/2) ./ sqrt(2*params(2)*params(4)*params(5));

% Vertical ascent model
modelFun = @(params,V) hoverPowerFun(params) ...
    + 0.5*params(1).*V ...
    + (params(2)/4).*params(3).*params(4).*V.^3 ...
    + (0.5*params(1) + (params(2)/4).*params(3).*params(4).*V.^2) .* ...
    sqrt((1+params(3)/params(5)).*V.^2 + (2*params(1))./(params(2).*params(4).*params(5)));

% Parameters vector:
% params = [W, n, S_fp_perp, rho, A, δ, s, C_T, k]

initParams = [15, 4, 0.02, 1.225, 0.5, 0.011, 0.045, 0.0012, 0.11];

% Fit using lsqcurvefit
opts = optimoptions('lsqcurvefit','Display','off');
fittedParams = lsqcurvefit(modelFun, initParams, samples.("TargetVz(m/s)"), samples.("AvgPower(W)"),[],[],opts);

% Plot fitted curve
hold on;
Vfit = linspace(0.5,5,100);
plot(Vfit, modelFun(fittedParams,Vfit),'b-','LineWidth',2);
legend('Representative Samples','Fitted Ascent Model','Location','northwest');

%% === Print fitted parameters ===
paramNames = {'W','n','S_fp_perp','rho','A','δ','s','C_T','k'};
resultsTable = table(paramNames', fittedParams', 'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for Vertical Ascent Model ===');
disp(resultsTable);
