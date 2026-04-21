%% Q1_filter_analysis.m - ECG Muscle Tremor Filter
% Systems and Control Theory - Take Home Exam 2026
% Question 1: Determine and verify the filter from the Bode plot
% =========================================================================
clear; close all; clc;

%% 1. Transfer Function from Bode Plot
% From Figure 1 Bode plot analysis:
%   - 0 dB at low freq, deep notch ~100 rad/s, LP rolloff ~1000 rad/s
%   - Phase: 0 deg -> -180 deg (2 excess poles)
%   - Filter = Notch (bandstop) + Low-pass (two 2nd-order sections)

% --- Notch filter parameters ---
wn    = 100;      % Notch frequency [rad/s] (~16 Hz, muscle tremor)
zeta1 = 0.05;     % Narrow notch -> small damping

% --- Low-pass filter parameters ---
wlp   = 1000;     % Cutoff frequency [rad/s] (~159 Hz)
zeta2 = 0.707;    % Butterworth response (no resonance peak)

% Notch: H1(s) = (s^2 + wn^2) / (s^2 + 2*zeta1*wn*s + wn^2)
H1 = tf([1, 0, wn^2], [1, 2*zeta1*wn, wn^2]);

% LP:   H2(s) = wlp^2 / (s^2 + 2*zeta2*wlp*s + wlp^2)
H2 = tf(wlp^2, [1, 2*zeta2*wlp, wlp^2]);

% Combined filter
H = H1 * H2;
fprintf('=== Combined Transfer Function ===\n');
disp(H);

%% 2. Electronic Circuit (draw on paper)
% STAGE 1 - NOTCH FILTER (parallel LC tank + shunt resistor):
%
%   V_in ---[ L1 || C1 ]---+--- V_mid
%                           |
%                          [R1]
%                           |
%                          GND
%
% Kirchhoff derivation:
%   Z_tank = sL1 / (s^2*L1*C1 + 1)
%   H1(s) = R1 / (Z_tank + R1)
%        = (s^2 + 1/(L1*C1)) / (s^2 + s/(R1*C1) + 1/(L1*C1))
%
% STAGE 2 - LOW-PASS (series RL + shunt C, buffered from Stage 1):
%
%   V_mid --[buffer]--[R2]--[L2]--+--- V_out
%                                  |
%                                 [C2]
%                                  |
%                                 GND
%
% Kirchhoff derivation:
%   H2(s) = (1/(L2*C2)) / (s^2 + s*R2/L2 + 1/(L2*C2))

%% 3. Component values & Kirchhoff verification
L1 = 1;       C1 = 100e-6;  R1 = 1000;     % Stage 1
L2 = 100e-3;  C2 = 10e-6;   R2 = 141.42;   % Stage 2

fprintf('=== Component Values ===\n');
fprintf('Notch:  L1=%.2f H, C1=%.0f uF, R1=%.0f Ohm\n', L1, C1*1e6, R1);
fprintf('LP:     L2=%.0f mH, C2=%.0f uF, R2=%.2f Ohm\n', L2*1e3, C2*1e6, R2);

% Verify parameters from component values
wn_check  = 1/sqrt(L1*C1);
z1_check  = 1/(2*R1*C1*wn_check);
wlp_check = 1/sqrt(L2*C2);
z2_check  = R2/(2*L2*wlp_check);

fprintf('\nKirchhoff verification:\n');
fprintf('  wn  = %.2f rad/s (expected %.2f)\n', wn_check, wn);
fprintf('  z1  = %.4f (expected %.4f)\n', z1_check, zeta1);
fprintf('  wlp = %.2f rad/s (expected %.2f)\n', wlp_check, wlp);
fprintf('  z2  = %.4f (expected %.4f)\n', z2_check, zeta2);

% Build TF from Kirchhoff-derived expressions
H1_K = tf([1, 0, 1/(L1*C1)], [1, 1/(R1*C1), 1/(L1*C1)]);
H2_K = tf(1/(L2*C2), [1, R2/L2, 1/(L2*C2)]);
H_K  = H1_K * H2_K;

%% 4. Pole-Zero Map
figure('Name','Q1 - Pole-Zero Map','NumberTitle','off');
pzmap(H);
title('Pole-Zero Map of ECG Tremor Filter');
grid on;
fprintf('\nPoles:\n'); disp(pole(H));
fprintf('Zeros:\n'); disp(zero(H));

%% 5. Bode Plot - Compare with Figure 1
figure('Name','Q1 - Bode Plot','NumberTitle','off');
bode(H, {1e-1, 1e5});
title('Bode Plot of ECG Tremor Filter (compare with Figure 1)');
grid on;

% Individual stages
figure('Name','Q1 - Individual Stages','NumberTitle','off');
subplot(2,1,1);
bode(H1, {1e-1, 1e5}); title('Stage 1: Notch Filter'); grid on;
subplot(2,1,2);
bode(H2, {1e-1, 1e5}); title('Stage 2: Low-Pass Filter'); grid on;

% Kirchhoff vs Bode-derived comparison
figure('Name','Q1 - Kirchhoff Verification','NumberTitle','off');
bode(H, 'b', H_K, 'r--', {1e-1, 1e5});
legend('From Bode plot reading', 'From Kirchhoff analysis');
title('Verification: Both methods give identical result');
grid on;

fprintf('\n=== Discussion ===\n');
fprintf('The Bode plot from the Kirchhoff-derived circuit matches exactly\n');
fprintf('with the transfer function read from the Bode plot in Figure 1.\n');
fprintf('This confirms the circuit implementation is correct.\n');
