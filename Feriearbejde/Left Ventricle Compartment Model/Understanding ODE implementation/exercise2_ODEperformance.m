function [] = exercise2_ODEperformance()
clear all
close all

k = 0.5;
x0 = 10;
t0 = 0;
tf=10;

for c = 1:13

    tol(c) = 10^(-c);
    options = odeset('Stats','on','RelTol',tol(c),'AbsTol',tol(c));
    
    disp(['##### tol: ' num2str(tol(c)) ' #####'])
    
    
    disp('いいい        ode45       いいい');
    tic
    [t_45,y_45] =  ode45(@dX1comp,[t0 tf],x0,options);
    time_45(c) = toc;
    steps_45(c) = length(t_45)-1;
    RSS_45 = 0;
    for (i=1:length(t_45))
    RSS_45 = RSS_45 + ((y_45(i)-x0*exp(-k*t_45(i))))^2;
    end
    RMSE_45(c) = sqrt(RSS_45/(length(t_45)-1));
    
    
    disp('いいい        ode23       いいい');
    tic
    [t_23,y_23] =  ode23(@dX1comp,[t0 tf],x0,options);
    time_23(c) = toc;
    steps_23(c) = length(t_23)-1;
    RSS_23 = 0;
    for (i=1:length(t_23))
    RSS_23 = RSS_23 + ((y_23(i)-x0*exp(-k*t_23(i))))^2;
    end
    RMSE_23(c) = sqrt(RSS_23/(length(t_23)-1));
    
    
    disp('いいい        ode113       いいい');
    tic
    [t_113,y_113] =  ode113(@dX1comp,[t0 tf],x0,options);
    time_113(c) = toc;
    steps_113(c) = length(t_113)-1;
    RSS_113 = 0;
    for (i=1:length(t_113))
    RSS_113 = RSS_113 + ((y_113(i)-x0*exp(-k*t_113(i))))^2;
    end
    RMSE_113(c) = sqrt(RSS_113/(length(t_113)-1));
end

%% plot RMSE
figure
%plot ode45
semilogx(tol,RMSE_45,'k--'); xlabel('tol'); ylabel('RMSE');
hold on
%plot ode23
semilogx(tol,RMSE_23,'r--');
%plot ode113
semilogx(tol,RMSE_113,'m--');
legend('ode45','ode23','ode113')

%% plot time
figure
%plot ode45
semilogx(tol,time_45,'k--'); xlabel('tol'); ylabel('time (sec)');
hold on
%plot ode23
semilogx(tol,time_23,'r--');
%plot ode113
semilogx(tol,time_113,'m--');
legend('ode45','ode23','ode113')

%% plot steps
figure
%plot ode45
semilogx(tol,steps_45,'k--'); xlabel('tol'); ylabel('steps');
hold on
%plot ode23
semilogx(tol,steps_23,'r--');
%plot ode113
semilogx(tol,steps_113,'m--');
legend('ode45','ode23','ode113')




