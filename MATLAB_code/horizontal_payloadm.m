% === Fixed parameters from horizontal fit ===
delta = 0.018;
s     = 0.047;
CT    = 0.0012841;
k     = 0.11;
Sfp   = 0.022797;
v0    = 6;          % mean induced velocity offset
rho   = 1.225;
A     = 0.385;      % rotor disc area (per rotor)
n     = 4;          % fixed rotor count

% Payload sweep (kg)
payload_values = 0.1:0.1:1.0;

% Horizontal speeds to evaluate
Vx_values = 0:2:10;   % 0,2,4,6,8,10 m/s

% Marker styles for each speed
markers = {'o','s','d','^','+','*'};
colors  = lines(length(Vx_values));

% Proposed horizontal flight model function (with variable W)
powerModelHor = @(W,n,V) ...
    (delta*s/(8*sqrt(rho*n*A))) .* (W/CT).^(3/2) ...
    + (3*delta*s/8) .* sqrt((W*rho*n*A)/CT) .* V.^2 ...
    + (1+k) .* W.^(3/2) ./ sqrt(2*rho*n*A) .* ...
    sqrt( sqrt(1 + (V.^4)./(4*v0.^4)) - (V.^2)./(2*v0.^2) ) ...
    + (n/2).*Sfp.*rho.*V.^3;

% Plot Power vs Payload for each horizontal speed
figure; hold on;
for j = 1:length(Vx_values)
    V = Vx_values(j);
    % Compute power for each payload (total weight = frame + payload)
    P = arrayfun(@(m) powerModelHor((3.0+m)*9.81,n,V), payload_values);
    plot(payload_values, P, ['-' markers{j}], ...
        'Color',colors(j,:),'LineWidth',2,'MarkerSize',7);

    % Percentage change from 0.1 kg to 1.0 kg payload
    Pmin = powerModelHor((3.0+0.1)*9.81,n,V);
    Pmax = powerModelHor((3.0+1.0)*9.81,n,V);
    percChange = ((Pmax - Pmin)/Pmin)*100;
    fprintf('Vx = %.1f m/s: Power change from 0.1kg to 1.0kg payload = %.2f %% (increase)\n', ...
        V, percChange);
end

xlabel('Payload Mass (kg)');
ylabel('Power Consumption (W)');
title('Proposed Horizontal Flight Model: Power vs Payload (n=4)');
legend(arrayfun(@(v) sprintf('V_x = %.1f m/s',v), Vx_values,'UniformOutput',false), ...
    'Location','northwest');
xlim([0.1 1.0]); ylim([350 600]); grid on;
