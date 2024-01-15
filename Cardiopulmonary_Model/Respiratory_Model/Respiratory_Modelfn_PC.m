function Respiratory_Modelfn(Ppl0,start_time,end_time)
%Computes the system of equations governing the equation of motion as a
%continious time derivative, controlled by driver function Pao
%   Detailed explanation goes here

global P
%% Plots
[Pao_plot,Ppl_plot,flow_plot,V_plot,Pvent_plot,Pmus_plot] = plots(0,1,1,1,1,0);

%% Loop Parameters
t = [start_time:P.resp.dt:end_time]; 
cnt = 1;

%% Initial Values
Ppl = 0+P.resp.PEEP; %Techically Ppl = -3 at start insp, but we assume the driving pressure creating flow, to be equal to PEEP 
Pao = P.resp.PEEP; %Initial Pao is PEEP [cmH2O]
V = (P.resp.Crs*P.resp.PEEP)*10^-3; %Initiel Volumen [L]
flow = 0;

%% System of Equations
for i = 1:length(t)       
    
    
    Pvent = Pvent_DriverPC(t(i)); %Pressure delivered by vent at t [cmH2O]

    
    flow=((Pvent-Ppl)/8); %[L/s] -> [L/min] at plot
    
    
    dV = (flow*P.resp.dt); % Volume is flow over time
    V = V + dV; %

    
    dPpl = flow*P.resp.dt/(P.resp.Crs*10^-3); %Change in pressure ((L/dt)*dt)/(L/P) =(P/dt)*dt = P

    
    Ppl = Ppl+dPpl; % Calculate Ppl
    
    cnt = cnt + 1;

    %% Housekeeping
    Housekeep(i,flow,V,Pvent,0,Ppl,0);    

end

disp('Simulation Done')

if Pvent_plot
figure(1)
plot(t,P.resp.Pvent)
title('Pvent')
ylabel('Pvent (cmH2O)')
xlabel('Time (S)')
end

if Ppl_plot
figure(2)
plot(t,P.resp.Ppl)
title('Ppl')
ylabel('Ppl (cmH2O)')
xlabel('Time (S)')
end

if flow_plot
figure(3)
plot(t,P.resp.flow*60);
title('flow')
ylabel('flow (L/min)')
xlabel('Time (S)')
end

if V_plot
figure(4)
plot(t,P.resp.V)
title('V')
ylabel('V (L)')
xlabel('Time (S)')
yticks([0,0.5,1,1.5,2,2.5,3,3.5,4])
%yline((P.resp.CL*P.resp.PEEP)*10^-3)
end



end

