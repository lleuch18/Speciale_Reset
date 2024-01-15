%% Initialize Variables
clc; clear all; close all;
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
P.resp.Te = P.resp.TCT-P.resp.Ti; %Inspiratory time seconds
P.resp.Trise = P.resp.Ti*0.2; % 20percent of Ti
P.resp.PSTrigger = -0.5; % Pmus pressuredrop before delivery of PS [cmH2O]

%Pmus settings
P.resp.PmusTi = 1.5; %Inspiratory time of Pmus [s]
P.resp.PmusTe = 2.5; %Expiratory time of Pmus [s]
P.resp.PmusPause = 0.2; %Pause between insp and exp phase [s]
P.resp.PmusSet = -12; %Pmus target to reach [cmH2O]
P.resp.PmusExpLgth = 0.60 %Length between end-inspiration and Pmus reaching 0
P.resp.PmusCycle = 2; %The flow in [L/S] at which Pmus cycles to passive expiration

%Simulation Parameters
P.resp.dt = 0.002; %2ms time steps
P.resp.sim_lgth = 5; %Simulation length in seconds
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


%% Cardio_pulmonary module test
%% Run cardiovascular Simulation
CircAdaptMainP


%% Run Respiratory Simulation
chunk = 1
Respiratory_Modelfn_PS(P.resp.Ppl0,0,P.resp.sim_lgth,chunk,1)

[Pao_plot,Ppl_plot,flow_plot,V_plot,Pvent_plot,Pmus_plot] = plots(1,1,1,1,1,1);

plot_on = true %Switch on/off for all plots

if plot_on
    
    if Pao_plot
    figure(1)
    plot(P.model{chunk}.Pao)
    title('Pao')
    ylabel('Pao (cmH2O)')
    xlabel('Time (S)')
    end
    
    if Ppl_plot
    figure(2)
    plot(P.model{chunk}.Ppl)
    title('Ppl')
    ylabel('Ppl (cmH2O)')
    xlabel('Time (S)')
    end
    
    if flow_plot
    figure(3)
    plot(P.model{chunk}.flow);%*60 for debugging purpose
    title('flow')
    ylabel('flow (L/min)')
    xlabel('Time (S)')
    end
    
    if V_plot
    figure(4)
    plot(P.model{chunk}.V)
    title('V')
    ylabel('V (L)')
    xlabel('Time (S)')
    %yticks([0,0.5,1,1.5,2,2.5,3,3.5,4])
    %yline((P.resp.CL*P.resp.PEEP)*10^-3)
    end
    
    if Pvent_plot
    figure(5)
    plot(P.model{chunk}.Pvent)
    title('Pvent')
    ylabel('P (cmH2O)')
    xlabel('Time (S)')
    end
    
    if Pmus_plot
    figure(6)
    plot(P.model{chunk}.Pmus)
    title('Pmus')
    ylabel('P (cmH2O)')
    xlabel('Time (S)')
    end
end





%% PuArt filter and plot
close all;
pSc= Rnd(0.1*P.General.p0);
figure(6);
p6=(GetFt('Node','p',{'PuArt'})/pSc)*round(7.5,3); %Convert to kPa and then CmH2O
p6 = p6+(P.General.p0/pSc)*round(7.5,3);
%p6=GetFt('Node','p',{'PuArt'});

beat_length = P.General.tCycle;

%1. find min value; 2. log values from min value to minvalue+beat length;
i_start = find(p6==min(p6))-(beat_length/P.General.Dt);%Shift 1 heart beat from min to not exceed array length
i_end = i_start+(beat_length/P.General.Dt);
proto = p6(i_start:i_end);

P.Nodes.pu_art_pre = zeros(length(P.resp.Ppl),1);
cnt=0;
for ia = 1:length(P.Nodes.pu_art_pre)
    
    
    if mod(ia,1000) == 0
        disp(['ran iteration nr at PuArt: ',num2str(ia)])
    end


    P.Nodes.pu_art_pre(ia) = proto(ia-cnt*(length(proto)));

    if mod(ia,round(length(proto))) == 0 && ia > 1
        cnt = cnt+1;
        disp(['cnt is:',num2str(cnt)])
        disp(['at ia+1: ',num2str(ia+1)])
        disp(['cnt*length ',num2str(cnt*length(proto))])
    end   
    

    if ia == length(p6)
        break
    end
end

%p7=p6(1:ia);


plot(P.Nodes.pu_art_pre);
title(['Pressure(',num2str((pSc/1e3)*round(7.5,3)),' mmHg)','Pre_Transmural']);
legend('PuArt_pre');



%% Intrathoracic Module
P.resp.alpha = 0.1;
disp(['pu_art pre Ppl: ', num2str(sum(P.Nodes.pu_art_pre))])
intrathoracic_model(P.resp.Ppl,P.resp.alpha)
disp(['pu_art post Ppl: ', num2str(sum(P.Nodes.pu_art_post))])

figure(7)
plot(P.Nodes.pu_art_post);
title(['Pressure(',num2str((pSc/1e3)*round(7.5,3)),' mmHg)','Post_Transmural']);
legend('PuArt_post');

figure(8)
plot(P.resp.Ppl);

%% Extract d3 & d4
%d3=maxinsp-minexp;
%d4=mininsp-maxexp;

%Each breath has its own d3 & d4
%insp_time is given from P&V framework

breaths = round(P.resp.sim_lgth/P.resp.TCT);
P.resp.d3 = zeros(length(breath,1));
P.resp.d4 = zeros(length(breath,1));
cnt=1;
for ia = 1:breaths
    max_insp = max(P.Nodes.pu_art_post(b_start:b_start+P.resp.Ti)); %%REMEMBER to ultimately use insp time detected in P&V framework
    min_insp = min(P.Nodes.pu_art_post(b_start:b_start+P.resp.Ti));

    max_exp = max(P.Nodes.pu_art_post(P.resp.Ti:P.resp.TCT));
    min_exp = min(P.Nodes.pu_art_post(P.resp.Ti:P.resp.TCT));

    P.resp.d3(ia) = max_insp-min_exp;
    P.resp.d4(ia) = mininsp-maxexp;
end

%% ========== AUXILARY FUNCTIONS =============

function X=Rnd(x)
X1= 10^round(log(x)/log(10));
X2=  2^round(log(x/X1)/log(2));
X=X1*X2;
end
