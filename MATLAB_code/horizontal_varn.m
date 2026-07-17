% === Fixed parameters from horizontal fit ===
delta = 0.018;
s     = 0.047;
CT    = 0.0012841;
k     = 0.11;
Sfp   = 0.022797;
v0    = 6;          % mean induced velocity offset
m     = 3;          % kg
W     = m*9.81;     % N
rho   = 1.225;
A     = 0.385;      % rotor disc area (per rotor)

% Rotor counts to sweep
n_values = [4 6 8 10 12];

% Horizontal speeds to evaluate
Vx_values = 0:2:10;   % 0,2,4,6,8,10 m/s

% Marker styles for each speed
markers = {'o','s','d','^','+','*'};
colors  = lines(length(Vx_values));

% Proposed horizontal flight model function
powerModelHor = @(n,V) ...
    (delta*s/(8*sqrt(rho*n*A))) .* (W/CT).^(3/2) ...
    + (3*delta*s/8) .* sqrt((W*rho*n*A)/CT) .* V.^2 ...
    + (1+k) .* W.^(3/2) ./ sqrt(2*rho*n*A) .* ...
    sqrt( sqrt(1 + (V.^4)./(4*v0.^4)) - (V.^2)./(2*v0.^2) ) ...
    + (n/2).*Sfp.*rho.*V.^3;

% Plot Power vs Rotor Count for each horizontal speed
figure; hold on;
for j = 1:length(Vx_values)
    V = Vx_values(j);
    P = arrayfun(@(n) powerModelHor(n,V), n_values);
    plot(n_values, P, ['-' markers{j}], ...
        'Color',colors(j,:),'LineWidth',2,'MarkerSize',7);

    % Percentage change from n=4 to n=12
    P4  = powerModelHor(4,V);
    P12 = powerModelHor(12,V);
    percChange = ((P12 - P4)/P4)*100;
    fprintf('Vx = %.1f m/s: Power change from n=4 to n=12 = %.2f %% (%s)\n', ...
        V, percChange, ternary(percChange>=0,'increase','decrease'));
end

xlabel('Number of Rotors');
ylabel('Power Consumption (W)');
title('Proposed Horizontal Flight Model: Power vs Rotor Count');
legend(arrayfun(@(v) sprintf('V_x = %.1f m/s',v), Vx_values,'UniformOutput',false), ...
    'Location','northeast');
xlim([4 12]); ylim([150 500]); grid on;

% Helper inline function
function out = ternary(cond,trueStr,falseStr)
if cond, out = trueStr; else, out = falseStr; end
end
