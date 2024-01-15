%% Parameters
clear all;
close all;

global P

%Lung Properties
P.resp.R = 2; %Resistance[cmH2O/(S/L)]
P.resp.Calv = 0.033; %Alveolar Compliance V/P
P.resp.Crs = 40; %%%%%%PATIENT SPECIFIC%%%%%%%% [mL/cmH2O] -> Remember to convert to [L/cmH2O]
P.resp.CL = 200; %%%%%%PATIENT SPECIFIC%%%%%%%% [mL/cmH2O] -> Remember to convert to [L/cmH2O]
P.resp.Cw = 120; %[ml/cmH2o] Calculated as 4% of standard vital capacity


%Vent Settings
P.resp.PS = 20; %Leveret Tryk
P.resp.PEEP = 5;
P.resp.RR = 12; %Respiratory rate in bpm
P.resp.TCT = 60/P.resp.RR; %Total Cycle Time in seconds
P.resp.Ti = 1.5 %Inspiratory time seconds   
P.resp.Te = 2.5 %Inspiratory time seconds
P.resp.Trise = P.resp.Ti*0.2; % 20percent of Ti
P.resp.PSTrigger = -1.5; % Pmus pressuredrop before delivery of PS [cmH2O]

%Pmus settings
P.resp.PmusTi = 1.5; %Inspiratory time of Pmus [s]
P.resp.PmusTe = 2.5; %Expiratory time of Pmus [s]
P.resp.PmusPause = 0.2; %Pause between insp and exp phase [s]
P.resp.PmusSet = -12; %Pmus target to reach [cmH2O]
P.resp.PmusExpLgth = 0.60 %Length between end-inspiration and Pmus reaching 0
P.resp.PMusCycle = 2; %The flow in [L/S] at which Pmus cycles to passive expiration

%Simulation Parameters
P.resp.dt = 0.002; %2ms time steps
P.resp.sim_lgth = 4; %Simulation length in seconds
P.resp.Tdeflate = 0.4; %Expiratory Time Contant in seconds
P.resp.cnt = 0; %Count for circumventing errors with indexing in Pmus_Vent


%Initial Values
P.resp.V0 = 3; %Initiel volumen 3L
P.resp.Palv0 = 5; %Initielt alveolært tryk 5CmH2O (PEEP)
P.resp.Pao0 = 0; %cmH2O
P.resp.flow0 = 0; %L/min
P.resp.Ppl0 = -3; %cmH2O
P.resp.PaoPrev = 0; %cmH2O Used for calculating dPao

%initial value vector
P.resp.SV0 = [P.resp.V0,P.resp.flow0,P.resp.Ppl0];%P.resp.Palv0, P.resp.Pao0,

%% PRESSURE SUPPORT One-Breath-Cycle time derivative 
clc;
close all;
%Allocate Memory
Memory_Allocation;

sim_dur = P.resp.sim_lgth;
P.resp.t_insp = [0:0.02:P.resp.sim_lgth];




PmusTe = 0.60;%P.resp.PmusTe;
PmusTi = P.resp.PmusTi;
PmusSet = P.resp.PmusSet;

P.resp.tempPmus = PmusSet*sin((pi/(2*PmusTi))*P.resp.t_insp);
P.resp.tempPmusInsp = P.resp.tempPmus(end:-1:1);

Respiratory_Modelfn_PS(P.resp.Ppl0,0,P.resp.sim_lgth);

%% PMUS Curve
clc; close all;
sim_dur = P.resp.sim_lgth;

PmusTe = 0.6;%P.resp.PmusTe;
PmusTi = P.resp.PmusTi;
PmusSet = P.resp.PmusSet;

%% Original Te
t_insp = [0:P.resp.dt:PmusTi];
t_exp = [0:P.resp.dt:PmusTe];

%% Full Period
t_insp = [0:P.resp.dt:4];
t_exp = [0:P.resp.dt:4]

%Pmus = zeros(length(t));



%%
clc;
close all;

%Pmus_insp = PmusSet*sin((pi/(2*PmusTi))*t_insp)'; %Original Pmus_Insp profile

Pmus_insp = P.resp.PSTrigger*sin((pi/(2*PmusTi))*t_insp)'; %Pmus_Insp with PSTrigger as origin


Pmus_exp = P.resp.PSTrigger*sin((pi/(2*PmusTe))*t_exp)'; Pmus_exp = Pmus_exp(end:-1:1); %Pmus_sxp as reverse of Pmus_insp

%Pmus_exp = P.resp.PSTrigger*sin((pi*(t_exp+PmusTe-2*PmusTi))/(2*(PmusTe-PmusTi))) %Pmusxp profile with start at PSTrigger

%Pmus_exp = PmusSet*sin((pi*(t_exp+PmusTe-2*PmusTi))/(2*(PmusTe-PmusTi))) %Original Pmusxp profile


subplot(2,1,1)
plot(Pmus_exp);
title('Pmus_exp [0.60s]')
yline(0)
xline(find(t_insp==PmusTe))
%yline(P.resp.PSTrigger)
subplot(2,1,2)
plot(Pmus_insp)
yline(0)
%yline(P.resp.PSTrigger)
xline(find(t_insp==PmusTi))
title('Pmus_insp [1.5s]')


%% PRESSURE CONTROL One-Breath-Cycle time derivative 
clc;
close all;
%Allocate Memory
Memory_Allocation;

Respiratory_Modelfn_PC(P.resp.Ppl0,0,P.resp.sim_lgth);



%% One-Breath-Cycle ODE
clc;

%Allocate Memory
Memory_Allocation;

%Set simulation duration
time_points = 0:P.resp.dt:P.resp.sim_lgth; %maybe from 0.02 since t0 may be initial value
%sim_duration; %Pre calculates the driver function
P.resp.index_mapping = time_points' %Maps timesteps to indexes, in order to access correct indexes in driver function

%Set Options
tol=1e-4; %tol= 1e-4 or 1e-5: trade off accuracy and calculation speed
opt = odeset('RelTol',tol,'AbsTol',tol);


diary Outputs
[tDummy,SVar] = ode113(@Respiratory_Modelfn,...
        time_points,P.resp.SV0,opt);
diary off

P.resp.V = SVar(:,1);
P.resp.flow = SVar(:,2);
P.resp.Ppl = SVar(:,3);

%% Plotting Results
%subplot(4,1,1);
plot(P.resp.Pao)
title('Pao/dT (cmH2O/s)')



%% Activation_Function Testing
%{
%t = [0:0.002:0.01]; %Condition 1
%t = [0.01:0.002:P.resp.Trise]; %Condition 2
%t = [P.resp.Trise:0.002:P.resp.Ti]; %Condition 3
%t = [P.resp.Ti:0.002:P.resp.Te+P.resp.Ti]; %Condition 4
t = [0:0.002:P.resp.Te+P.resp.Ti]; %Full Duration

cnt = 1;

P.resp.Pao = zeros(length(t),1);

for i = 1:length(t);
    %disp(['i is: ',num2str(i)]);
    %disp(['t is: ',num2str(t(i))]);
    P.resp.Pao(cnt) = Activation_Function(t(i));
    cnt = cnt + 1;

end

plot(t,P.resp.Pao);
%}
