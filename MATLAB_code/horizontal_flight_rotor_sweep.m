% Rotor count range (even numbers)
rotorCounts = 4:2:12;
speeds = [0 3 6 9 12 15];

% Preallocate
powerMatrix_prop = zeros(length(rotorCounts), length(speeds));
powerMatrix_apm  = zeros(length(rotorCounts), length(speeds));

for i = 1:length(rotorCounts)
    n = rotorCounts(i);
    for j = 1:length(speeds)
        V = speeds(j);
        % Proposed model
        powerMatrix_prop(i,j) = powerModelProposedHor(params_fit_prop, V);
        % APM model
        powerMatrix_apm(i,j)  = powerModelAPMHor(params_fit_apm, V);
    end
end

% Plot Proposed model curves
figure; hold on;
colors = lines(length(speeds));
for j = 1:length(speeds)
    plot(rotorCounts, powerMatrix_prop(:,j), 'LineWidth',2, 'Color',colors(j,:));
end
xlabel('Number of Rotors');
ylabel('Power (W)');
title('Forward Flight: Rotor Count vs Power (Proposed Model)');
legend(arrayfun(@(v) sprintf('V = %.1f m/s',v), speeds,'UniformOutput',false));
grid on;

% Plot APM model curves
figure; hold on;
for j = 1:length(speeds)
    plot(rotorCounts, powerMatrix_apm(:,j), 'LineWidth',2, 'Color',colors(j,:));
end
xlabel('Number of Rotors');
ylabel('Power (W)');
title('Forward Flight: Rotor Count vs Power (APM Model)');
legend(arrayfun(@(v) sprintf('V = %.1f m/s',v), speeds,'UniformOutput',false));
grid on;
