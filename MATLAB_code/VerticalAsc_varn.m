% Fixed parameters from ascent fit
delta = 0.010827;
s     = 0.044281;
CT    = 0.001223;
k     = 0.11416;
Sfp   = 0.009;
W     = 29.43;
rho   = 1.225;
A     = 0.385;

% Rotor counts to sweep
n_values = [4 6 8 10 12];

% Ascent speeds to evaluate
Va_values = [1 2 3 4 5 6];

% Marker styles for each speed
markers = {'o','s','d','^','+','*'};   % circle, square, diamond, triangle, plus, star
colors  = lines(length(Va_values));

% Proposed ascent model function
powerModelAscent = @(n,V) ...
    (delta*s/(8*sqrt(n*rho*A))) .* (W/CT).^(3/2) ...
    + (1+k) .* W.^(3/2) ./ sqrt(2*n*rho*A) ...
    + 0.5*W.*V ...
    + (n/4).*Sfp.*rho.*V.^3 ...
    + (0.5*W + (n/4).*Sfp.*rho.*V.^2) .* ...
    sqrt((1+Sfp/A).*V.^2 + (2*W)./(n.*rho.*A));

% Plot Power vs Rotor Count for each ascent speed
figure; hold on;
for j = 1:length(Va_values)
    V = Va_values(j);
    P = arrayfun(@(n) powerModelAscent(n,V), n_values);
    plot(n_values, P, ['-' markers{j}], ...
        'Color',colors(j,:),'LineWidth',2,'MarkerSize',7);

    % Percentage change from n=4 to n=12
    P4  = powerModelAscent(4,V);
    P12 = powerModelAscent(12,V);
    percChange = ((P12 - P4)/P4)*100;
    fprintf('Va = %.1f m/s: Power change from n=4 to n=12 = %.2f %% (%s)\n', ...
        V, percChange, ternary(percChange>=0,'increase','decrease'));
end

xlabel('Number of Rotors');
ylabel('Power Consumption (W)');
title('Proposed Vertical Ascent Model: Power vs Rotor Count');
legend(arrayfun(@(v) sprintf('V_a = %.1f m/s',v), Va_values,'UniformOutput',false), ...
    'Location','northeast');
xlim([4 12]); ylim([200 500]); grid on;

% Helper inline function
function out = ternary(cond,trueStr,falseStr)
if cond, out = trueStr; else, out = falseStr; end
end
