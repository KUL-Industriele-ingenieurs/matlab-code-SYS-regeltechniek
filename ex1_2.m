% Exercise 1.2 — plot responses
% define time vector (long enough for the smallest ω0 = 0.1 to settle)
t = 0:0.01:50;  % seconds

% 1.1 en 1.2
a = (3/2)*(1 - exp(-2*t));
figure(1)
plot(t, a, 'LineWidth', 1.2)
xlabel('Time (s)')
ylabel('a(t)')
title('a(t) = (3/2)*(1 - e^{-2t})')
grid on

b = 1 + exp(-t).*(2*sin(2*t) - cos(2*t));
figure(2)
plot(t, b, 'LineWidth', 1.2)
grid on


% 1.3
w0_vals = [0.1, 1, 10];
C = zeros(numel(w0_vals), numel(t));
for k = 1:numel(w0_vals)
    w0 = w0_vals(k);
    C(k, :) = 5*(1 - (1 + w0.*t).*exp(-w0.*t));
end

figure(3)
h = plot(t, C(1,:), 'b-', t, C(2,:), 'r--', t, C(3,:), 'm-.', 'LineWidth', 1.5);
% ensure ω0 = 10 is visible and highlighted (no markers)
set(h(3), 'Visible', 'on', 'Color', [0.85, 0.33, 0.10], 'LineWidth', 1.5, 'Marker', 'none');
grid on
legend(h, '\omega_0 = 0.1','\omega_0 = 1','\omega_0 = 10','Location','Best')
xlim([0, 50])   
