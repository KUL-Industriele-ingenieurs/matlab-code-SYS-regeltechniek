% Exercise 1.3 — frequency response for H1(s) = 8 s / (s^2 + 8 s + 25)
% Compute H1(jw), plot magnitude and phase on one figure (two subplots)

% frequency vector (rad/s)
w = linspace(0,50,2000);

% complex frequency s = j*w
s = 1j*w;

% transfer function H1(s)
H1 = (8*s) ./ (s.^2 + 8*s + 25); % 1.3.1
H2 = ((2^2)+16)./(s.^2 + 8*s + 16); % 1.3.2
H3 = 8./((s.^2 + 8*s + 16).*(s+1)); % 1.3.3
H4 = (s.^2)./(s.^2 + 4*s + 16); % 1.3.4
H5 = s.^2./((s.^2 + 4*s + 20).*(s.^2 + 6*s + 10)); % 1.3.5
H6 = (s.^2 - 8*s + 16)./(s.^2 + 4*s + 16); % 1.3.6


% amplitude and phase
magH1 = abs(H2);
phaseH1 = unwrap(angle(H2)) * (180/pi);  % degrees

% Plot
figure(1)
subplot(2,1,1)
plot(w, magH1, 'b', 'LineWidth', 1.5)
grid on
xlabel('\omega (rad/s)')
ylabel('|H_1(j\omega)|')
title('Magnitude of H_1(j\omega)')
xlim([0 max(w)])

subplot(2,1,2)
plot(w, phaseH1, 'r', 'LineWidth', 1.5)
grid on
xlabel('\omega (rad/s)')
ylabel('Phase of H_1(j\omega) (deg)')
title('Phase of H_1(j\omega)')
xlim([0 max(w)])

sgtitle('Frequency response of H_1(s) = 8 s / (s^2 + 8 s + 25)')

% optional: display peak magnitude and corresponding frequency
[peakMag, idx] = max(magH1);
peakFreq = w(idx);
fprintf('Peak magnitude = %g at \omega = %g rad/s\n', peakMag, peakFreq);
