% Fixed parameters
delta = 0.010674;
s     = 0.043648;
CT    = 0.0012435;
k     = 0.10813;
Sfp   = 0.48;
W     = 29.43;
rho   = 1.225;
A     = 0.385;

% Rotor counts to sweep
n_values = [4 6 8 10 12];

% Descent speeds to evaluate
Vd_values = [0.5 1 1.5 2 2.5 3];

% Marker styles for each speed
markers = {'o','s','d','^','+','*'};   % circle, square, diamond, triangle, plus, star
colors  = lines(length(Vd_values));    % distinct colors

% Proposed descent model function
powerModel = @(n,V) ...
    (delta*s/(8*sqrt(n*rho*A))) .* (W/CT).^(3/2) ...
    + (1+k) .* W.^(3/2) ./ sqrt(2*n*rho*A) ...
    + 0.5*W.*V ...
    - (n/4).*Sfp.*rho.*V.^3 ...
    + (0.5*W - (n/4).*Sfp.*rho.*V.^2) .* ...
    sqrt((1 - Sfp/A).*V.^2 + (2*W)./(n.*rho.*A));

% Plot Power vs Rotor Count for each descent speed
figure; hold on;
for j = 1:length(Vd_values)
    V = Vd_values(j);
    P = arrayfun(@(n) powerModel(n,V), n_values);
    plot(n_values, P, ['-' markers{j}], ...
        'Color',colors(j,:),'LineWidth',2,'MarkerSize',7);
end

xlabel('Number of Rotors');
ylabel('Power Consumption (W)');
title('Proposed Vertical Descent Model: Power vs Rotor Count');
legend(arrayfun(@(v) sprintf('V_d = %.1f m/s',v), Vd_values,'UniformOutput',false), ...
    'Location','northeast');
xlim([4 12]); ylim([100 400]); grid on;
