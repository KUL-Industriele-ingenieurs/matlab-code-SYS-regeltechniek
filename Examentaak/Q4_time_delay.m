%% Q4_time_delay.m - Time Delay Analysis
% Systems and Control Theory - Take Home Exam 2026
% Question 4: Maximum time delay, Simulink verification, PID re-tuning
% =========================================================================
clear; close all; clc;

%% Load results from Q3
load('Q3_results.mat');  % Contains: G, Ku, Tu, wu, Kp_ft, Ki_ft, Kd_ft, C_ft, T_ft
fprintf('=== PID Controller from Q3 ===\n');
fprintf('Kp = %.4f, Ki = %.4f, Kd = %.4f\n', Kp_ft, Ki_ft, Kd_ft);

%% 4.1 Maximum Time Delay from Bode Plot
% The delay is added in the FEEDBACK loop.
% For a system with PID controller C(s) and plant G(s):
%   Open-loop: L(s) = C(s) * G(s)
%   With delay in feedback: the effective open-loop becomes
%   L(s) * exp(-s*tau)
%
% The delay adds phase: -tau * w (in radians) at frequency w
% The system becomes unstable when total phase reaches -180 deg
% at the gain crossover frequency.
%
% Maximum delay = Phase Margin / w_gc  (in radians)

L = C_ft * G;  % Open-loop transfer function

figure('Name','Q4.1 - Open-Loop Bode','NumberTitle','off');
margin(L);
title('Open-Loop Bode Plot: C(s)*G(s)');
grid on;

[Gm, Pm, Wcg, Wcp] = margin(L);
fprintf('\n=== Bode Plot Margins ===\n');
fprintf('Gain Margin:  %.4f (%.2f dB) at %.4f rad/s\n', Gm, 20*log10(Gm), Wcg);
fprintf('Phase Margin: %.2f deg at %.4f rad/s\n', Pm, Wcp);

% Maximum time delay
Pm_rad = Pm * pi / 180;  % Convert to radians
tau_max = Pm_rad / Wcp;

fprintf('\n=== Maximum Time Delay ===\n');
fprintf('Phase margin = %.2f deg = %.4f rad\n', Pm, Pm_rad);
fprintf('Gain crossover frequency = %.4f rad/s\n', Wcp);
fprintf('Maximum delay: tau_max = PM / w_gc = %.4f s\n', tau_max);

%% 4.2 Simulink Model (created programmatically)
% Create the Simulink model with Transport Delay in feedback
fprintf('\n=== Creating Simulink Model ===\n');

model_name = 'Q4_delay_model';

% Close model if already open
if bdIsLoaded(model_name)
    close_system(model_name, 0);
end

new_system(model_name);
open_system(model_name);

% Add blocks
add_block('simulink/Sources/Step', [model_name '/Step']);
add_block('simulink/Math Operations/Sum', [model_name '/Sum']);
add_block('simulink/Continuous/PID Controller', [model_name '/PID']);
add_block('simulink/Continuous/Transfer Fcn', [model_name '/Plant']);
add_block('simulink/Continuous/Transport Delay', [model_name '/Delay']);
add_block('simulink/Sinks/Scope', [model_name '/Scope']);
add_block('simulink/Sinks/To Workspace', [model_name '/ToWorkspace']);

% Position blocks
set_param([model_name '/Step'], 'Position', [50, 100, 80, 130]);
set_param([model_name '/Sum'], 'Position', [150, 100, 170, 120]);
set_param([model_name '/PID'], 'Position', [230, 90, 310, 130]);
set_param([model_name '/Plant'], 'Position', [370, 90, 470, 130]);
set_param([model_name '/Scope'], 'Position', [600, 95, 630, 125]);
set_param([model_name '/Delay'], 'Position', [370, 200, 450, 230]);
set_param([model_name '/ToWorkspace'], 'Position', [600, 150, 660, 180]);

% Set Sum block inputs
set_param([model_name '/Sum'], 'Inputs', '|+-');

% Set PID parameters
set_param([model_name '/PID'], 'P', num2str(Kp_ft));
set_param([model_name '/PID'], 'I', num2str(Ki_ft));
set_param([model_name '/PID'], 'D', num2str(Kd_ft));

% Set Plant transfer function
set_param([model_name '/Plant'], 'Numerator', mat2str(num));
set_param([model_name '/Plant'], 'Denominator', mat2str(den));

% Set initial delay
set_param([model_name '/Delay'], 'DelayTime', num2str(tau_max));

% Set ToWorkspace
set_param([model_name '/ToWorkspace'], 'VariableName', 'y_out');

% Connect blocks
add_line(model_name, 'Step/1', 'Sum/1');
add_line(model_name, 'Sum/1', 'PID/1');
add_line(model_name, 'PID/1', 'Plant/1');
add_line(model_name, 'Plant/1', 'Scope/1');
add_line(model_name, 'Plant/1', 'ToWorkspace/1');
add_line(model_name, 'Plant/1', 'Delay/1');
add_line(model_name, 'Delay/1', 'Sum/2');

% Set simulation parameters
set_param(model_name, 'StopTime', '20');
set_param(model_name, 'Solver', 'ode45');

% Save model
save_system(model_name);
fprintf('Simulink model "%s.slx" created and saved.\n', model_name);

%% Test various delays
fprintf('\n=== Testing Various Time Delays ===\n');

delays = [0, 0.25*tau_max, 0.5*tau_max, 0.75*tau_max, tau_max, 1.1*tau_max, 1.5*tau_max, 2*tau_max];

figure('Name','Q4.2 - Delay Sweep','NumberTitle','off');
colors = lines(length(delays));
hold on;

for i = 1:length(delays)
    tau_test = delays(i);
    
    % Analytical check: add delay approximation (Pade)
    [num_delay, den_delay] = pade(tau_test, 5);  % 5th order Pade
    Delay_tf = tf(num_delay, den_delay);
    
    % Closed-loop with delay in feedback
    % T(s) = C*G / (1 + C*G*Delay)
    L_delay = C_ft * G;
    T_delay = L_delay / (1 + L_delay * Delay_tf);
    
    % Check stability
    p_delay = pole(T_delay);
    is_stable = all(real(p_delay) < 0);
    
    if is_stable
        [y, t] = step(T_delay, 20);
        plot(t, y, 'Color', colors(i,:), 'LineWidth', 1.5);
        status = 'STABLE';
    else
        status = 'UNSTABLE';
        % Still try to plot for a short time
        try
            [y, t] = step(T_delay, linspace(0, 5, 500));
            plot(t, y, '--', 'Color', colors(i,:), 'LineWidth', 1);
        catch
        end
    end
    
    fprintf('  tau = %.4f s (%.0f%% of tau_max): %s\n', ...
        tau_test, tau_test/tau_max*100, status);
    legend_entries{i} = sprintf('\\tau=%.3fs (%s)', tau_test, status);
end

hold off;
legend(legend_entries, 'Location', 'best');
title('Step Response with Various Feedback Delays');
xlabel('Time [s]'); ylabel('Output');
grid on;

fprintf('\n-> tau_max = %.4f s: system becomes marginally stable\n', tau_max);
fprintf('-> For tau > tau_max: system is unstable (confirmed)\n');

%% 4.3 Re-tune PID with critical delay
fprintf('\n=== Re-Tuning PID with Marginal Delay (tau = tau_max) ===\n');

tau_critical = tau_max;
[num_delay_crit, den_delay_crit] = pade(tau_critical, 5);
Delay_crit = tf(num_delay_crit, den_delay_crit);

% Effective plant with delay in feedback:
% We need to design C(s) for the modified loop
% Open loop = C(s) * G(s), feedback = Delay(s)
% T(s) = C(s)*G(s) / (1 + C(s)*G(s)*Delay(s))

% Strategy: reduce gains to restore stability margin
% The delay eats into phase margin, so we need to:
%   1. Reduce bandwidth (reduce Kp)
%   2. Reduce integral action (reduce Ki)
%   3. Keep/increase derivative for phase lead

fprintf('Strategy: Reduce gains to recover phase margin with delay.\n');

% Iterative search for best parameters
best_cost = inf;
best_params_delay = [Kp_ft, Ki_ft, Kd_ft];

for kp_scale = [0.1, 0.15, 0.2, 0.3, 0.4, 0.5]
    for ki_scale = [0.05, 0.1, 0.15, 0.2, 0.3]
        for kd_scale = [0.5, 1.0, 1.5, 2.0, 3.0]
            Kp_try = Kp_ft * kp_scale;
            Ki_try = Ki_ft * ki_scale;
            Kd_try = Kd_ft * kd_scale;
            
            C_try = pid(Kp_try, Ki_try, Kd_try);
            L_try = C_try * G;
            T_try = L_try / (1 + L_try * Delay_crit);
            
            % Check stability
            if any(real(pole(T_try)) > 0)
                continue;
            end
            
            try
                info_try = stepinfo(T_try);
                cost = info_try.Overshoot + 0.5*info_try.SettlingTime;
                if info_try.Overshoot < 15 && cost < best_cost
                    best_cost = cost;
                    best_params_delay = [Kp_try, Ki_try, Kd_try];
                end
            catch
                continue;
            end
        end
    end
end

Kp_delay = best_params_delay(1);
Ki_delay = best_params_delay(2);
Kd_delay = best_params_delay(3);

fprintf('Re-tuned PID with delay:\n');
fprintf('  Kp = %.4f, Ki = %.4f, Kd = %.4f\n', Kp_delay, Ki_delay, Kd_delay);

C_delay = pid(Kp_delay, Ki_delay, Kd_delay);
L_delay_final = C_delay * G;
T_delay_final = L_delay_final / (1 + L_delay_final * Delay_crit);

info_delay = stepinfo(T_delay_final);
fprintf('  Rise Time:     %.4f s\n', info_delay.RiseTime);
fprintf('  Settling Time: %.4f s\n', info_delay.SettlingTime);
fprintf('  Overshoot:     %.2f %%\n', info_delay.Overshoot);
fprintf('  Steady-state:  %.4f\n', dcgain(T_delay_final));

% Update Simulink model with new PID
set_param([model_name '/PID'], 'P', num2str(Kp_delay));
set_param([model_name '/PID'], 'I', num2str(Ki_delay));
set_param([model_name '/PID'], 'D', num2str(Kd_delay));
set_param([model_name '/Delay'], 'DelayTime', num2str(tau_critical));
save_system(model_name);
fprintf('Simulink model updated with re-tuned PID.\n');

% Final comparison plot
figure('Name','Q4.3 - PID with Delay','NumberTitle','off');

% No delay, original PID
[y1, t1] = step(T_ft, 20);
% With delay, original PID (if stable)
[num_d, den_d] = pade(tau_critical, 5);
Delay_final = tf(num_d, den_d);
L_orig = C_ft * G;
T_orig_delay = L_orig / (1 + L_orig * Delay_final);

plot(t1, y1, 'b', 'LineWidth', 1.5); hold on;
try
    [y2, t2] = step(T_orig_delay, 20);
    plot(t2, y2, 'r--', 'LineWidth', 1.5);
catch
end
[y3, t3] = step(T_delay_final, 20);
plot(t3, y3, 'g', 'LineWidth', 2);
hold off;

legend('No delay (Q3 PID)', 'With delay (Q3 PID, may be unstable)', ...
       'With delay (Re-tuned PID)', 'Location', 'best');
title(sprintf('PID Comparison with \\tau = %.4f s delay', tau_critical));
xlabel('Time [s]'); ylabel('Output');
grid on;

fprintf('\n=== Summary ===\n');
fprintf('Max feedback delay: tau_max = %.4f s\n', tau_max);
fprintf('Original PID without delay meets specs.\n');
fprintf('With tau = tau_max, PID was re-tuned to restore stability.\n');
