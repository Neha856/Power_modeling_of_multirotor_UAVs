% Fixed parameters (from fit)
delta = 0.010674;
s     = 0.043648;
CT    = 0.0012435;
k     = 0.10813;
Sfp   = 0.48;
rho   = 1.225;
A     = 0.385;
n     = 4; % fixed rotor count

% Payload sweep (kg)
payload_values = 0.1:0.1:1.0;

% Descent speeds to evaluate
Vd_values = [0.5 1 1.5 2 2.5 3];

% Marker styles for each speed
markers = {'o','s','d','^','+','*'};
colors  = lines(length(Vd_values));

% Proposed descent model function (with variable W)
powerModel = @(W,n,V) ...
    (delta*s/(8*sqrt(n*rho*A))) .* (W/CT).^(3/2) ...
    + (1+k) .* W.^(3/2) ./ sqrt(2*n*rho*A) ...
    + 0.5*W.*V ...
    - (n/4).*Sfp.*rho.*V.^3 ...
    + (0.5*W - (n/4).*Sfp.*rho.*V.^2) .* ...
    sqrt((1 - Sfp/A).*V.^2 + (2*W)./(n.*rho.*A));

% Plot Power vs Payload for each descent speed
figure; hold on;
for j = 1:length(Vd_values)
    V = Vd_values(j);
    P = arrayfun(@(m) powerModel((3.0+m)*9.81,n,V), payload_values); % W = (frame+payload)*g
    plot(payload_values, P, ['-' markers{j}], ...
        'Color',colors(j,:),'LineWidth',2,'MarkerSize',7);

    % Percentage change from 0.1 kg to 1.0 kg
    Pmin = powerModel((3.0+0.1)*9.81,n,V);
    Pmax = powerModel((3.0+1.0)*9.81,n,V);
    percChange = ((Pmax - Pmin)/Pmin)*100;
    fprintf('Vd = %.1f m/s: Power change from 0.1kg to 1.0kg payload = %.2f %% (increase)\n', ...
        V, percChange);
end

xlabel('Payload Mass (kg)');
ylabel('Power Consumption (W)');
title('Proposed Vertical Descent Model: Power vs Payload (n=4)');
legend(arrayfun(@(v) sprintf('V_d = %.1f m/s',v), Vd_values,'UniformOutput',false), ...
    'Location','northwest');
xlim([0.1 1.0]); ylim([300 550]); grid on;
