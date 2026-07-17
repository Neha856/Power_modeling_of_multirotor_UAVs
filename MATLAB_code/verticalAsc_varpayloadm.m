% Fixed parameters from ascent fit
delta = 0.010827;
s     = 0.044281;
CT    = 0.001223;
k     = 0.11416;
Sfp   = 0.009;
rho   = 1.225;
A     = 0.385;
n     = 4; % fixed rotor count

% Payload sweep (kg)
payload_values = 0.1:0.1:1.0;

% Ascent speeds to evaluate
Va_values = [1 2 3 4 5 6];

% Marker styles for each speed
markers = {'o','s','d','^','+','*'};
colors  = lines(length(Va_values));

% Proposed ascent model function (with variable W)
powerModelAscent = @(W,n,V) ...
    (delta*s/(8*sqrt(n*rho*A))) .* (W/CT).^(3/2) ...
    + (1+k) .* W.^(3/2) ./ sqrt(2*n*rho*A) ...
    + 0.5*W.*V ...
    + (n/4).*Sfp.*rho.*V.^3 ...
    + (0.5*W + (n/4).*Sfp.*rho.*V.^2) .* ...
    sqrt((1+Sfp/A).*V.^2 + (2*W)./(n.*rho.*A));

% Plot Power vs Payload for each ascent speed
figure; hold on;
for j = 1:length(Va_values)
    V = Va_values(j);
    % Compute power for each payload (total weight = frame + payload)
    P = arrayfun(@(m) powerModelAscent((3.0+m)*9.81,n,V), payload_values);
    plot(payload_values, P, ['-' markers{j}], ...
        'Color',colors(j,:),'LineWidth',2,'MarkerSize',7);

    % Percentage change from 0.1 kg to 1.0 kg payload
    Pmin = powerModelAscent((3.0+0.1)*9.81,n,V);
    Pmax = powerModelAscent((3.0+1.0)*9.81,n,V);
    percChange = ((Pmax - Pmin)/Pmin)*100;
    fprintf('Va = %.1f m/s: Power change from 0.1kg to 1.0kg payload = %.2f %% (increase)\n', ...
        V, percChange);
end

xlabel('Payload Mass (kg)');
ylabel('Power Consumption (W)');
title('Proposed Vertical Ascent Model: Power vs Payload (n=4)');
legend(arrayfun(@(v) sprintf('V_a = %.1f m/s',v), Va_values,'UniformOutput',false), ...
    'Location','northwest');
xlim([0.1 1.0]); ylim([300 700]); grid on;
