% === Load CSV with preserved column names ===
data = readtable('vertical_descent_data_unequal.csv','VariableNamingRule','preserve');

% Convert Timestamp to datetime
data.Timestamp = datetime(data.Timestamp,'InputFormat','yyyy-MM-dd HH:mm:ss');

% Create timetable
tt = table2timetable(data,'RowTimes','Timestamp');

% Resample to 1 Hz with mean
tt1Hz = retime(tt,'regular','mean','TimeStep',seconds(1));

% === Convert velocities and target speeds to absolute values ===
tt1Hz.("Vz(m/s)")       = abs(tt1Hz.("Vz(m/s)"));
tt1Hz.("TargetVz(m/s)") = abs(tt1Hz.("TargetVz(m/s)"));

% === Relative tolerance filtering (20% of TargetVz) ===
tolFactor = 0.2; % 20% tolerance
diffVz = abs(tt1Hz.("Vz(m/s)") - tt1Hz.("TargetVz(m/s)"));
tol = tolFactor .* tt1Hz.("TargetVz(m/s)");
validRows = diffVz <= tol;

filteredData = tt1Hz(validRows,:);

% Save filtered dataset
writetable(timetable2table(filteredData),'vertical_descent_filtered_20tol_1Hz.csv');

% === Plot BEFORE filtering (Power vs Actual Velocity) ===
figure;
scatter(tt1Hz.("Vz(m/s)"), tt1Hz.("Power(W)"), 25, 'b','filled');
xlabel('Actual Vertical Velocity (m/s)');
ylabel('Power (W)');
title('Power vs Actual Velocity (Before Filtering)');
xlim([0 3.5]);
ylim([0 600]);
grid on;
xticks(0:0.5:3.5);

% === Plot AFTER filtering (Power vs Target Speed) ===
figure;
scatter(filteredData.("TargetVz(m/s)"), filteredData.("Power(W)"), 25, 'r','filled');
xlabel('Target Vertical Speed (m/s)');
ylabel('Power (W)');
title('Power vs Target Speed (After Filtering)');
xlim([0 3.5]);
ylim([0 600]);
grid on;
xticks(0:0.5:3.5);
