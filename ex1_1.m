
%% Define signals
%sampling time
Ts=1e-6;
Tfinal=1e-3;

t=[0:Ts:Tfinal];

%The first variable is a current i1 like defined below
i1=(1000t*sin(10^5*t)+0.01*sin(3*10^5*t+1))*e^(-10000*t);

%The second variable is the current i2
i2=(sin(10^5*t(1:1000))+i1(0))*(i1(2000)+I1(10));

%% Plot
plot(t,[i1,i2])
xlabel('Time [s]')
ylabel('Current [A]')
title('Exercise 1.1')
legend('Current i1','Current i2')