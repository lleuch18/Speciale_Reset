function [] = exercise1_findDt()
k= 0.5
x0 = 10;
t0 = 0;
tf=10;
maxRMSE = 0.02;
dt = [0.01 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1];

RMSE_rk1 = zeros(size(dt));
RMSE_rk2 = zeros(size(dt));
RMSE_rk4 = zeros(size(dt));

for i=1:length(dt)
    [RMSE, nFEval] = x1comp_solExercise1(k,x0,t0,dt(i),tf,0)
    RMSE_rk1(i) = RMSE(1); 
    RMSE_rk2(i) = RMSE(2);
    RMSE_rk4(i) = RMSE(3);
    
    nFEval_rk1(i) = nFEval(1); 
    nFEval_rk2(i) = nFEval(2);
    nFEval_rk4(i) = nFEval(3);
end

%% plot RMSE
figure
%plot rk1
plot(dt,RMSE_rk1,'k--'); xlabel('dt'); ylabel('RMSE');
hold on
%plot rk2
plot(dt,RMSE_rk2,'r--');
%plot rk4
plot(dt,RMSE_rk4,'m--');
%plot error limit
plot([dt(1) dt(end)],[maxRMSE maxRMSE],'k:');
legend('Euler 1 step','Runge-Kutta 2nd order','Runge-Kutta 4th order')

%% plot nFEval
figure
%plot rk1
plot(dt,nFEval_rk1,'k--'); xlabel('dt'); ylabel('nFEval');
hold on
%plot rk2
plot(dt,nFEval_rk2,'r--');
%plot rk4
plot(dt,nFEval_rk4,'m--');
%plot error limit
plot([dt(1) dt(end)],[max(nFEval) max(nFEval)],'k:');
legend('Euler 1 step','Runge-Kutta 2nd order','Runge-Kutta 4th order')