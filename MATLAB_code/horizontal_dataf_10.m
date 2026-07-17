% === Step 1: Read CSV file ===
data = readtable('horizontal_flight_data_full.csv','VariableNamingRule','preserve');
data.Timestamp = datetime(data.Timestamp,'InputFormat','yyyy-MM-dd HH:mm:ss');

% Create timetable
tt = table2timetable(data,'RowTimes','Timestamp');

% === Step 2: Resample to 1 Hz ===
tt1Hz = retime(tt,'regular','mean','TimeStep',seconds(1));

% === Step 3: Apply acceleration filter ===
f0 = 1;   % Hz
a0 = 0.5; % m/s^2 threshold
Vi = tt1Hz.("Velocity(m/s)");
dV = diff(Vi);
acc = abs(dV * f0);

validAccel = true(size(Vi));
validAccel(2:end) = acc <= a0;

% === Step 4: Apply target-speed tolerance filter ===
tolFactor = 0.1;
diffVel = abs(tt1Hz.("Velocity(m/s)") - tt1Hz.("TargetSpeed(m/s)"));
tol = tolFactor .* tt1Hz.("TargetSpeed(m/s)");
zeroMask = tt1Hz.("TargetSpeed(m/s)") == 0;
validTol = (diffVel <= tol & ~zeroMask) | (zeroMask & diffVel <= 0.2);

% === Step 5: Combine both filters ===
validRows = validAccel & validTol;
filteredData = tt1Hz(validRows,:);

% Save filtered dataset
writetable(timetable2table(filteredData),'horizontal_filtered_final_1Hz.csv');

% === Step 6: Average power per integer speed step (0–10 m/s) ===
TargetVx = filteredData.("TargetSpeed(m/s)");
Power    = filteredData.("Power(W)");
TargetVxInt = round(TargetVx);
filteredData.TargetVxInt = TargetVxInt;

uniqueSpeeds = (0:10)';
avgPower = zeros(size(uniqueSpeeds));
for i = 1:length(uniqueSpeeds)
    mask = filteredData.TargetVxInt == uniqueSpeeds(i);
    if any(mask)
        avgPower(i) = mean(Power(mask));
    else
        avgPower(i) = NaN;
    end
end
samples = table(uniqueSpeeds, avgPower, ...
    'VariableNames', {'TargetVx(m/s)','AvgPower(W)'});

% === Step 7: Fixed constants ===
fixed_m   = 3;
fixed_W   = fixed_m * 9.81;
fixed_n   = 4;
fixed_rho = 1.225;
fixed_A   = 0.385*4;
fixed_k2  = sqrt(2*fixed_rho*0.385);

% === Step 8: Proposed Horizontal Flight Model (Eq. 8) ===
powerModelProposedHor = @(params, V) ...
    (params(1)*params(2)/(8*sqrt(fixed_rho*fixed_A))) .* (fixed_W/params(3)).^(3/2) ...
    + (3*params(1)*params(2)/8) .* sqrt((fixed_W*fixed_rho*fixed_A)/params(3)) .* V.^2 ...
    + (1+params(4)) .* fixed_W.^(3/2) ./ sqrt(2*fixed_rho*fixed_A) .* ...
    sqrt( sqrt(1 + (V.^4)./(4*params(6).^4)) - (V.^2)./(2*params(6).^2) ) ...
    + (fixed_n/2)*params(5).*fixed_rho.*V.^3;

x0_prop = [0.01, 0.04, 0.001, 0.1, 0.009, 5];
lb_prop = [0.005, 0.04, 0.0005, 0.11, 0, 4];
ub_prop = [0.018, 0.047, 0.002, 0.2, 0.1, 6];

opts = optimoptions('lsqcurvefit','Display','off');
validMask = ~isnan(samples.("AvgPower(W)"));
params_fit_prop = lsqcurvefit(powerModelProposedHor, x0_prop, ...
    samples.("TargetVx(m/s)")(validMask), samples.("AvgPower(W)")(validMask), ...
    lb_prop, ub_prop, opts);
P_fit_prop = powerModelProposedHor(params_fit_prop, samples.("TargetVx(m/s)"));

paramNamesProp = {'δ','s','C_T','k','S_fp_parallel','v0'};
resultsTableProp = table(paramNamesProp', params_fit_prop', ...
    'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for Proposed Horizontal Flight Model ===');
disp(resultsTableProp);

% === Step 9: APM Aerodynamic Horizontal Model ===
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

paramNamesAPM = {'k1','c2','c4','c5'};
resultsTableAPM = table(paramNamesAPM', params_fit_apm', ...
    'VariableNames', {'Parameter','FittedValue'});
disp('=== Fitted Parameters for APM Horizontal Flight Model ===');
disp(resultsTableAPM);

% === Step 10: Relative Differences ===
relDiffProp = mean(abs(P_fit_prop(validMask) - samples.("AvgPower(W)")(validMask)) ...
    ./ samples.("AvgPower(W)")(validMask)) * 100;
relDiffAPM  = mean(abs(P_fit_apm(validMask)  - samples.("AvgPower(W)")(validMask)) ...
    ./ samples.("AvgPower(W)")(validMask)) * 100;

hoverMask = samples.("TargetVx(m/s)") == 0;
hoverDiffProp = mean(abs(P_fit_prop(hoverMask) - samples.("AvgPower(W)")(hoverMask)) ...
    ./ samples.("AvgPower(W)")(hoverMask)) * 100;
hoverDiffAPM  = mean(abs(P_fit_apm(hoverMask)  - samples.("AvgPower(W)")(hoverMask)) ...
    ./ samples.("AvgPower(W)")(hoverMask)) * 100;

fprintf('Average Relative Difference (Proposed Model): %.2f %%\n', relDiffProp);
fprintf('Average Relative Difference (APM Model): %.2f %%\n', relDiffAPM);
fprintf('Hover Relative Difference (Proposed Model): %.2f %%\n', hoverDiffProp);
fprintf('Hover Relative Difference (APM Model): %.2f %%\n', hoverDiffAPM);

% === Step 11: Comparison Table ===
comparisonTable = table(samples.("TargetVx(m/s)"), samples.("AvgPower(W)"), ...
    P_fit_prop, P_fit_apm, ...
    'VariableNames', {'TargetSpeed','MeasuredAvgPower','ProposedFit','APMFit'});
disp('=== Measured vs Fitted Power at Each Speed Step ===');
disp(comparisonTable);

% === Step 12: Plot Results ===
%% === Step 12a: Plot BEFORE Filtering (Raw Data) ===
figure;
scatter(tt1Hz.("TargetSpeed(m/s)"), tt1Hz.("Power(W)"), 25, 'b','filled'); 
xlabel('Horizontal Speed (m/s)');
ylabel('Power (W)');
title('Raw Data Before Filtering');
xlim([0 11]); ylim([0 600]); xticks(0:1:10); grid on;

%% === Step 12b: Plot AFTER Filtering with Avg + Fits ===
figure;

% Filtered data in light red plus markers
scatter(filteredData.("TargetSpeed(m/s)"), filteredData.("Power(W)"), 25, ...
    '+','MarkerEdgeColor',[1 0.6 0.6]); hold on;

% Average values in dark red filled circles
plot(samples.("TargetVx(m/s)"), samples.("AvgPower(W)"), 'ro', ...
    'MarkerFaceColor',[0.6 0 0], 'MarkerSize',5);

% Proposed model fit (normal blue solid curve)
plot(samples.("TargetVx(m/s)"), P_fit_prop, 'b-','LineWidth',2);

% APM model fit (magenta dash-dot curve)
plot(samples.("TargetVx(m/s)"), P_fit_apm, 'm-.','LineWidth',2);

xlabel('Horizontal Speed (m/s)');
ylabel('Average Power (W)');
title('Filtered Data, Power-Speed Samples, and Model Fits (0–10 m/s)');
legend('Filtered Data','Power-Speed Samples','Proposed Model','APM Model');
xlim([-1 11]); ylim([0 600]); xticks(0:1:10); grid on;
