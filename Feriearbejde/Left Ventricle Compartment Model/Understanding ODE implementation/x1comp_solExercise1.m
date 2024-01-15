function [RMSE, nFEval] = x1comp_solExercise1(k,x0,t0,dt,tf,plotOn)

%% intialise variables
t = [t0:dt:tf];
x = zeros(size(t));
x(1) = x0;

%% Solve function with Euler steps (first order Runge-Kutta)
nFEval = 0; 
for (i=1:length(t))
    %Calculate derivative
    dx = -k*x(i);
    %Calculate the next volume.
    if (i<length(t))
        x(i+1) = x(i) + dt*dx;
    end
    nFEval = nFEval + 1;
end

%% Solve function with midpoint method (second order Runge-Kutta)
x_rk2 = zeros(size(t));
x_rk2(1) = x0;
nFEval_rk2 = 0; 
for (i=1:length(t))
    %Calculate derivative
    dx = -k*x_rk2(i);
    %Calculate the next volume.
    if (i<length(t))
        k1 = dt*dx;
        dx_2 = -k*(x_rk2(i)+0.5*k1);   %only half step in x, as derivative does not depend on t
        k2 = dt*dx_2;
        x_rk2(i+1) = x_rk2(i) + k2;
        
        nFEval_rk2 = nFEval_rk2 + 2;
    else
        nFEval_rk2 = nFEval_rk2 + 1;
    end
end

%% Solve function with fourth order Runge-Kutta
x_rk4 = zeros(size(t));
x_rk4(1) = x0;
nFEval_rk4 = 0;
for (i=1:length(t))
    %Calculate derivative
    dx = -k*x_rk4(i);
    %Calculate the next volume.
    if (i<length(t))
        k1 = dt*dx;
        dx_2 = -k*(x_rk4(i)+0.5*k1);   %only half step in x, as derivative does not depend on t
        k2 = dt*dx_2;
        dx_3 = -k*(x_rk4(i)+0.5*k2);   %only half step in x, as derivative does not depend on t
        k3 = dt*dx_3;
        dx_4 = -k*(x_rk4(i)+k3);   %only step in x, as derivative does not depend on t
        k4 = dt*dx_4;
        x_rk4(i+1) = x_rk4(i) + (1/6)*k1 + (1/3)*k2 + (1/3)*k3 + (1/6)*k4;
        
        nFEval_rk4 = nFEval_rk4 + 4;
    else
        nFEval_rk4 = nFEval_rk4 + 1;
    end
end

%% Algebraic solution
ta = [t0:0.01:tf];
xa = x0*exp(-k*ta);

%% Error in fit between numerical and algebraic
% Residual Sum of Squares
RSS = 0;
RSS_rk2 = 0;
RSS_rk4 = 0;
for (i=1:length(t))
    RSS = RSS + ((x(i)-x0*exp(-k*t(i))))^2;
    RSS_rk2 = RSS_rk2 + ((x_rk2(i)-x0*exp(-k*t(i))))^2;
    RSS_rk4 = RSS_rk4 + ((x_rk4(i)-x0*exp(-k*t(i))))^2;
end
% Root Mean Square Error
RMSE = sqrt(RSS/(length(t)-1));
RMSE_rk2 = sqrt(RSS_rk2/(length(t)-1));
RMSE_rk4 = sqrt(RSS_rk4/(length(t)-1));

disp(['Runge-Kutta 1st order RMSE:'  num2str(RMSE)]);
disp(['Runge-Kutta 2nd order RMSE:'  num2str(RMSE_rk2)]);
disp(['Runge-Kutta 4th order RMSE:'  num2str(RMSE_rk4)]);

%% plot results if plotOn = 1
if nargin>2
    if plotOn
        figure
        %plot x
        plot(t,x,'k--'); ylabel('x'); xlabel('Time (s)');
        hold on
        %plot x_rk2
        plot(t,x_rk2,'r--'); 
        %plot x_rk4
        plot(t,x_rk4,'m--'); 
        %plot algebraic solution
        plot(ta,xa,'b-'); 
        title(['k = ' num2str(k) ', dt = ' num2str(dt)]);
        legend('x(t) Euler 1 step','x(t) Runge-Kutta 2nd order','x(t) Runge-Kutta 4th order','x(t) Algrebraic solution')
    end
end

RMSE = [RMSE RMSE_rk2 RMSE_rk4];
nFEval = [nFEval nFEval_rk2 nFEval_rk4];