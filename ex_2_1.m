% Oefening 2.1 - Bal valt in olie.
% m*dv/dt = m*g - beta*v

v0_cm = 40;            % initial speed given in cm/s (from assignment)
v0 = v0_cm / 100;      % convert to m/s for SI consistency
m = 0.01;              % kg
beta = 0.1;            % Ns/m
g = 9.81;              % m/s^2

tau = m / beta;        % time constant (s)
v_inf = (m * g) / beta;% terminal velocity (steady-state)

% time vector (cover several time constants)
t = 0:0.001:1;         % 1 s is 10*tau (tau = 0.1 s)

% analytic solution (simplified grouping)
v = v_inf + (v0 - v_inf) * exp(-(beta/m) * t);

% plot
figure(1)
plot(t, v, 'b-', 'LineWidth', 1.6);
hold on;
plot(t, v_inf * ones(size(t)), 'k--', 'LineWidth', 1);
xlabel('Time t (s)');
ylabel('Velocity v(t) (m/s)');
title('Ball falling in oil: v(t) = mg/\beta + (v_0 - mg/\beta)e^{-\beta t/m}');
legend('v(t)', 'steady-state mg/\beta', 'Location', 'Best');
grid on;
xlim([0 max(t)]);
hold off;

% display characteristics
fprintf('v(inf) = %.4f m/s (%.2f cm/s) - time constant tau = %.4f s\n', v_inf, v_inf*100, tau);