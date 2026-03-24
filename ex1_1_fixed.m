
%% Define signals
%sampling time
Ts=1e-6;
Tfinal=1e-3;

t=0:Ts:Tfinal;

%The first variable is a current i1 like defined below
i1=(1000*t.*sin(10^5*t)+0.01*sin(3*10^5*t+1)).*exp(-10000*t);

%The second variable is the current i2
i2 = (sin(10^5*t) + i1(1)) .* (i1(end) + i1(10));  % use full `t` and elementwise multiplication

%% Plot
plot(t, i1, t, i2)
xlabel('Time [s]')
ylabel('Current [A]')
title('Exercise 1.1')
legend('Current i1','Current i2')