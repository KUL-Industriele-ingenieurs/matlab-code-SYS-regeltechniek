%% Q2_P_controller.m - Stability Analysis & P Controller Design
% Systems and Control Theory - Take Home Exam 2026
% Question 2: Analyze stability and design a P controller
% =========================================================================
clear; close all; clc;

%% Load the assigned transfer function
load('tf01.mat');
fprintf('=== Assigned Transfer Function ===\n');
disp(sys);

% Extract numerator and denominator
[num, den] = tfdata(sys, 'v');
G = tf(num, den);

%% 2.1 Stability Analysis
fprintf('=== Open-Loop Stability Analysis ===\n');
p = pole(G);
fprintf('Poles of G(s):\n');
for i = 1:length(p)
    fprintf('  p%d = %.4f + %.4fi  (real part: %.4f)\n', i, real(p(i)), imag(p(i)), real(p(i)));
end

if all(real(p) < 0)
    fprintf('-> System is STABLE (all poles have negative real parts)\n');
elseif any(real(p) > 0)
    fprintf('-> System is UNSTABLE (poles with positive real parts exist)\n');
else
    fprintf('-> System is MARGINALLY STABLE (poles on imaginary axis)\n');
end

% Plot 1: Pole-Zero Map
figure('Name','Q2 - Pole-Zero Map','NumberTitle','off');
pzmap(G);
title('Open-Loop Pole-Zero Map');
grid on;

% Plot 2: Step Response (if stable or to show instability)
figure('Name','Q2 - Open-Loop Step Response','NumberTitle','off');
try
    step(G, 10);
    title('Open-Loop Step Response');
    grid on;
catch
    t = linspace(0, 5, 1000);
    [y, t] = step(G, t);
    plot(t, y); title('Open-Loop Step Response (may be unstable)');
    grid on; xlabel('Time [s]'); ylabel('Amplitude');
end

% Plot 3: Impulse Response
figure('Name','Q2 - Open-Loop Impulse Response','NumberTitle','off');
impulse(G, 10);
title('Open-Loop Impulse Response');
grid on;

% Plot 4: Nyquist Plot
figure('Name','Q2 - Nyquist Plot','NumberTitle','off');
nyquist(G);
title('Nyquist Plot of G(s)');
grid on;

%% 2.2 P Controller Design
% Closed-loop: T(s) = K*G(s) / (1 + K*G(s))

% (a) Bode plot analysis to find gain margin
figure('Name','Q2 - Open-Loop Bode','NumberTitle','off');
margin(G);
title('Bode Plot of G(s) with Margins');
grid on;

[Gm, Pm, Wcg, Wcp] = margin(G);
fprintf('\n=== Bode Plot Analysis ===\n');
fprintf('Gain Margin:     %.4f (%.2f dB) at %.4f rad/s\n', Gm, 20*log10(Gm), Wcg);
fprintf('Phase Margin:    %.2f deg at %.4f rad/s\n', Pm, Wcp);
fprintf('-> Max K before instability (from GM): K_max = %.4f\n', Gm);

% (b) Root Locus
figure('Name','Q2 - Root Locus','NumberTitle','off');
rlocus(G);
title('Root Locus of G(s)');
grid on;
% Add stability boundary
sgrid;

% Find K values where roots cross imaginary axis
[r, k] = rlocus(G);
% Find crossing of imaginary axis
for i = 1:size(r,2)
    for j = 1:size(r,1)
        if i > 1
            if real(r(j,i)) * real(r(j,i-1)) < 0  % sign change
                K_cross = k(i);
                fprintf('Root locus crosses imaginary axis near K = %.4f\n', K_cross);
            end
        end
    end
end

% (c) Marginally stable P controller
% K for marginal stability = Gain Margin
Ku = Gm;  % Ultimate gain
fprintf('\n=== Marginally Stable P Controller ===\n');
fprintf('K_u (marginally stable) = %.4f\n', Ku);

% Verify: closed-loop poles at marginal stability
T_marginal = feedback(Ku * G, 1);
p_marginal = pole(T_marginal);
fprintf('Closed-loop poles at K = K_u:\n');
for i = 1:length(p_marginal)
    fprintf('  p%d = %.4f + %.4fi\n', i, real(p_marginal(i)), imag(p_marginal(i)));
end

% Find oscillation period Tu for Ziegler-Nichols (needed in Q3)
% Imaginary poles give the oscillation frequency
imag_parts = abs(imag(p_marginal));
wu = max(imag_parts(imag_parts > 0.01));  % oscillation frequency
Tu = 2*pi/wu;
fprintf('Oscillation frequency at marginal stability: wu = %.4f rad/s\n', wu);
fprintf('Oscillation period: Tu = %.4f s\n', Tu);

% (d) Choose a specific K value
% Strategy: Use about 50% of the gain margin for adequate stability margin
K_chosen = 0.5 * Ku;
fprintf('\n=== Chosen P Controller ===\n');
fprintf('K_p = %.4f (50%% of K_u for adequate stability margin)\n', K_chosen);

T_chosen = feedback(K_chosen * G, 1);
fprintf('Closed-loop poles with chosen K:\n');
p_cl = pole(T_chosen);
for i = 1:length(p_cl)
    fprintf('  p%d = %.4f + %.4fi\n', i, real(p_cl(i)), imag(p_cl(i)));
end

% Step response of chosen controller
figure('Name','Q2 - Closed-Loop Step Response (P)','NumberTitle','off');
step(T_chosen);
title(sprintf('Closed-Loop Step Response with K_p = %.4f', K_chosen));
grid on;
stepinfo_cl = stepinfo(T_chosen);
fprintf('\nStep response characteristics:\n');
fprintf('  Rise Time:     %.4f s\n', stepinfo_cl.RiseTime);
fprintf('  Settling Time: %.4f s\n', stepinfo_cl.SettlingTime);
fprintf('  Overshoot:     %.2f %%\n', stepinfo_cl.Overshoot);
fprintf('  Steady-state:  %.4f\n', dcgain(T_chosen));

% Save results for Q3
save('Q2_results.mat', 'G', 'Ku', 'Tu', 'wu', 'K_chosen', 'num', 'den');
fprintf('\nResults saved to Q2_results.mat for use in Q3.\n');
