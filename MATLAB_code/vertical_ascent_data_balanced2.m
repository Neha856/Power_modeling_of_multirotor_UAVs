% === Load CSV with preserved column names ===
data = readtable('vertical_ascent_data_balanced2.csv','VariableNamingRule','preserve');

% Convert Timestamp to datetime
data.Timestamp = datetime(data.Timestamp,'InputFormat','yyyy-MM-dd HH:mm:ss');

% Create timetable
tt = table2timetable(data,'RowTimes','Timestamp');

% Resample to 1 Hz with mean
tt1Hz = retime(tt,'regular','mean','TimeStep',seconds(1));

% === Relative tolerance filtering ===
tolFactor = 0.2; % 20% of TargetVz
diffVz = abs(tt1Hz.("Vz(m/s)") - tt1Hz.("TargetVz(m/s)"));
tol = tolFactor .* tt1Hz.("TargetVz(m/s)");
validRows = diffVz <= tol;

filteredData = tt1Hz(validRows,:);

% Save filtered dataset
writetable(timetable2table(filteredData),'vertical_ascent_filtered_balanced2a_1Hz.csv');

% === Plot BEFORE filtering (Power vs Target Speed) ===
figure;
scatter(tt1Hz.("TargetVz(m/s)"), tt1Hz.("Power(W)"), 25, 'b','filled');
xlabel('Target Vertical Speed (m/s)');
ylabel('Power (W)');
title('Power vs Target Speed (Before Filtering)');
xlim([0 5]);
ylim([0 600]);
grid on;
xticks(0:0.5:5);

% === Plot AFTER filtering (Power vs Target Speed) ===
figure;
scatter(filteredData.("TargetVz(m/s)"), filteredData.("Power(W)"), 25, 'r','filled');
xlabel('Target Vertical Speed (m/s)');
ylabel('Power (W)');
title('Power vs Target Speed (After Filtering)');
xlim([0 5]);
ylim([0 600]);
grid on;
xticks(0:0.5:5);
