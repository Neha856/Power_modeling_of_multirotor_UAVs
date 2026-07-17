% Horizontal Flight Data Processing
% Merge Part1 + Part2, filter with 10% tolerance (including 0 m/s case),
% resample at 1 Hz, plot before/after filtering, save filtered data.

% === Step 1: Read both CSV files ===
data1 = readtable('horizontal_flight_data_part1.csv','VariableNamingRule','preserve');
data2 = readtable('horizontal_flight_data_part2.csv','VariableNamingRule','preserve');

% Merge into one table
data = [data1; data2];

% === Step 2: Convert Timestamp to datetime ===
data.Timestamp = datetime(data.Timestamp,'InputFormat','yyyy-MM-dd HH:mm:ss');

% Create timetable
tt = table2timetable(data,'RowTimes','Timestamp');

% === Step 3: Resample to 1 Hz ===
tt1Hz = retime(tt,'regular','mean','TimeStep',seconds(1));

% === Step 4: Apply 10% tolerance filter ===
tolFactor = 0.1;  % 10% tolerance
diffVel = abs(tt1Hz.("Velocity(m/s)") - tt1Hz.("TargetSpeed(m/s)"));
tol = tolFactor .* tt1Hz.("TargetSpeed(m/s)");

% Special case for 0 m/s target: allow ±0.2 m/s
zeroMask = tt1Hz.("TargetSpeed(m/s)") == 0;
validRows = (diffVel <= tol & ~zeroMask) | (zeroMask & diffVel <= 0.2);

filteredData = tt1Hz(validRows,:);

% === Step 5: Save filtered dataset ===
writetable(timetable2table(filteredData), 'horizontal_flight_filtered_1Hz.csv');

% === Step 6: Plot Before Filtering ===
figure;
scatter(tt1Hz.("TargetSpeed(m/s)"), tt1Hz.("Power(W)"), 25, 'b','filled');
xlabel('Target Speed (m/s)');
ylabel('Power (W)');
title('Power vs Speed (Before Filtering)');
xlim([-1 16]);   % extend axis to show 0 m/s
ylim([0 600]);
grid on;
xticks(0:1:15);

% === Step 7: Plot After Filtering ===
figure;
scatter(filteredData.("TargetSpeed(m/s)"), filteredData.("Power(W)"), 25, 'r','filled');
xlabel('Target Speed (m/s)');
ylabel('Power (W)');
title('Power vs Speed (After Filtering)');
xlim([-1 16]);   % extend axis to show 0 m/s
ylim([0 600]);
grid on;
xticks(0:1:15);
