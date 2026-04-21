%% Q3_PID_controller.m - PID Controller Design
% Systems and Control Theory - Take Home Exam 2026
% Question 3: PID with Ziegler-Nichols, use case, and fine-tuning
% =========================================================================
clear; close all; clc;

%% Load results from Q2
load('Q2_results.mat');  % Contains: G, Ku, Tu, wu, K_chosen, num, den
fprintf('=== Transfer Function ===\n');
disp(G);
fprintf('From Q2: Ku = %.4f, Tu = %.4f s\n', Ku, Tu);

%% 3.1 Ziegler-Nichols PID Tuning
% Using the ultimate gain method:
%   Ku = ultimate gain (from Q2, gain margin)
%   Tu = ultimate period (from Q2, oscillation period at marginal stability)
%
% Ziegler-Nichols PID formulas:
%   Kp = 0.6 * Ku
%   Ti = Tu / 2        (integral time)
%   Td = Tu / 8        (derivative time)
%   Ki = Kp / Ti       (integral gain)
%   Kd = Kp * Td       (derivative gain)

Kp_zn = 0.6 * Ku;
Ti_zn = Tu / 2;
Td_zn = Tu / 8;
Ki_zn = Kp_zn / Ti_zn;
Kd_zn = Kp_zn * Td_zn;

fprintf('\n=== Ziegler-Nichols PID Parameters ===\n');
fprintf('Kp = %.4f\n', Kp_zn);
fprintf('Ki = %.4f  (Ti = %.4f s)\n', Ki_zn, Ti_zn);
fprintf('Kd = %.4f  (Td = %.4f s)\n', Kd_zn, Td_zn);

% PID controller: C(s) = Kp + Ki/s + Kd*s = (Kd*s^2 + Kp*s + Ki) / s
C_zn = pid(Kp_zn, Ki_zn, Kd_zn);
fprintf('\nZiegler-Nichols PID controller:\n');
disp(C_zn);

% Closed-loop with Z-N PID
T_zn = feedback(C_zn * G, 1);

figure('Name','Q3.1 - Z-N PID Step Response','NumberTitle','off');
step(T_zn, 10);
title('Step Response with Ziegler-Nichols PID');
grid on;

info_zn = stepinfo(T_zn);
fprintf('Z-N Step response:\n');
fprintf('  Rise Time:     %.4f s\n', info_zn.RiseTime);
fprintf('  Settling Time: %.4f s\n', info_zn.SettlingTime);
fprintf('  Overshoot:     %.2f %%\n', info_zn.Overshoot);
fprintf('  Steady-state:  %.4f\n', dcgain(T_zn));

%% 3.2 Use Case Description
% =========================================================================
% USE CASE: Temperature Control in an Industrial Oven
% =========================================================================
% A bakery uses an industrial oven where precise temperature control is
% critical for consistent product quality.
%
% Input:  Desired temperature setpoint (e.g., 180°C for bread)
% Output: Actual oven temperature measured by thermocouple
%
% Customer requirements:
%   - Overshoot < 5% (prevent burning / food safety)
%   - Settling time < 30 s (production efficiency)
%   - Zero steady-state error (consistent baking quality)
%   - Smooth response (no aggressive actuator action)
%
% The plant G(s) models the heating element + oven thermal dynamics.
% =========================================================================

fprintf('\n=== Use Case: Industrial Oven Temperature Control ===\n');
fprintf('Goals:\n');
fprintf('  - Overshoot     < 5%%\n');
fprintf('  - Settling time < 30 s\n');
fprintf('  - Steady-state error = 0\n');
fprintf('  - Smooth, damped response\n');

%% 3.3 Fine-Tuned PID Controller
% Start from Z-N parameters and adjust:
%   - Reduce Kp to decrease overshoot
%   - Adjust Ki to maintain zero SSE without too much integral windup
%   - Increase Kd for better damping

% Fine-tuning strategy:
% Z-N typically gives ~25% overshoot. To reduce to <5%:
%   - Reduce Kp by factor ~0.5
%   - Reduce Ki slightly (increase Ti)
%   - Increase Kd for more damping

Kp_ft = Kp_zn * 0.4;
Ki_ft = Ki_zn * 0.3;
Kd_ft = Kd_zn * 1.5;

fprintf('\n=== Fine-Tuned PID Parameters ===\n');
fprintf('Kp = %.4f (was %.4f, reduced to lower overshoot)\n', Kp_ft, Kp_zn);
fprintf('Ki = %.4f (was %.4f, reduced to avoid integral windup)\n', Ki_ft, Ki_zn);
fprintf('Kd = %.4f (was %.4f, increased for damping)\n', Kd_ft, Kd_zn);

C_ft = pid(Kp_ft, Ki_ft, Kd_ft);
T_ft = feedback(C_ft * G, 1);

% Compare Z-N vs fine-tuned
figure('Name','Q3.3 - PID Comparison','NumberTitle','off');
step(T_zn, 'b', T_ft, 'r', 10);
legend('Ziegler-Nichols PID', 'Fine-Tuned PID');
title('Step Response Comparison: Z-N vs Fine-Tuned');
grid on;

info_ft = stepinfo(T_ft);
fprintf('\nFine-tuned step response:\n');
fprintf('  Rise Time:     %.4f s\n', info_ft.RiseTime);
fprintf('  Settling Time: %.4f s\n', info_ft.SettlingTime);
fprintf('  Overshoot:     %.2f %%\n', info_ft.Overshoot);
fprintf('  Steady-state:  %.4f\n', dcgain(T_ft));

% Check if goals are met
fprintf('\n=== Goal Assessment ===\n');
if info_ft.Overshoot < 5
    fprintf('[PASS] Overshoot = %.2f%% < 5%%\n', info_ft.Overshoot);
else
    fprintf('[ADJUST] Overshoot = %.2f%% >= 5%% - needs further tuning\n', info_ft.Overshoot);
end
if info_ft.SettlingTime < 30
    fprintf('[PASS] Settling time = %.4f s < 30 s\n', info_ft.SettlingTime);
else
    fprintf('[ADJUST] Settling time = %.4f s >= 30 s\n', info_ft.SettlingTime);
end
fprintf('Steady-state value: %.4f (goal: 1.0000)\n', dcgain(T_ft));

% Iterative tuning loop - try multiple combinations
fprintf('\n=== Automated Fine-Tuning Sweep ===\n');
best_cost = inf;
best_params = [Kp_ft, Ki_ft, Kd_ft];

for kp_scale = [0.2, 0.3, 0.4, 0.5, 0.6]
    for ki_scale = [0.1, 0.2, 0.3, 0.5]
        for kd_scale = [1.0, 1.5, 2.0, 3.0]
            Kp_try = Kp_zn * kp_scale;
            Ki_try = Ki_zn * ki_scale;
            Kd_try = Kd_zn * kd_scale;
            C_try = pid(Kp_try, Ki_try, Kd_try);
            T_try = feedback(C_try * G, 1);
            
            % Check stability
            if any(real(pole(T_try)) > 0)
                continue;
            end
            
            try
                info_try = stepinfo(T_try);
                % Cost: penalize overshoot >5%, settling >30s
                cost = info_try.Overshoot + 0.5*info_try.SettlingTime;
                if info_try.Overshoot < 5 && info_try.SettlingTime < 30 && cost < best_cost
                    best_cost = cost;
                    best_params = [Kp_try, Ki_try, Kd_try];
                end
            catch
                continue;
            end
        end
    end
end

if best_cost < inf
    Kp_best = best_params(1);
    Ki_best = best_params(2);
    Kd_best = best_params(3);
    C_best = pid(Kp_best, Ki_best, Kd_best);
    T_best = feedback(C_best * G, 1);
    info_best = stepinfo(T_best);
    
    fprintf('Best parameters found:\n');
    fprintf('  Kp = %.4f, Ki = %.4f, Kd = %.4f\n', Kp_best, Ki_best, Kd_best);
    fprintf('  Overshoot:     %.2f %%\n', info_best.Overshoot);
    fprintf('  Settling Time: %.4f s\n', info_best.SettlingTime);
    fprintf('  Rise Time:     %.4f s\n', info_best.RiseTime);
    
    figure('Name','Q3.3 - Best PID','NumberTitle','off');
    step(T_zn, 'b--', T_best, 'r', 10);
    legend('Ziegler-Nichols', 'Optimized PID');
    title('Optimized PID Step Response');
    grid on;
    
    % Use best parameters
    Kp_ft = Kp_best; Ki_ft = Ki_best; Kd_ft = Kd_best;
    C_ft = C_best; T_ft = T_best;
end

% Bode plot of the fine-tuned open loop
figure('Name','Q3.3 - Open-Loop Bode with PID','NumberTitle','off');
margin(C_ft * G);
title('Open-Loop Bode: Fine-Tuned PID * G(s)');
grid on;

% Critical reflection
fprintf('\n=== Critical Reflection ===\n');
fprintf('The Ziegler-Nichols method provides a good starting point but\n');
fprintf('typically results in ~25%% overshoot. For our oven application,\n');
fprintf('this was unacceptable (burning risk). By reducing Kp and Ki\n');
fprintf('while increasing Kd, we achieved a more damped response with\n');
fprintf('acceptable settling time. The trade-off is slower rise time,\n');
fprintf('which is acceptable for thermal systems.\n');

% Save for Q4
save('Q3_results.mat', 'G', 'Ku', 'Tu', 'wu', 'Kp_ft', 'Ki_ft', 'Kd_ft', 'C_ft', 'T_ft', 'num', 'den');
fprintf('\nResults saved to Q3_results.mat for use in Q4.\n');
