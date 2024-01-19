function negative_pressure_ventilation(Ppl0,start_time,end_time)
% Models the respiratory system during Negative Pressure Ventilation (NPV)
global P

%% Loop Parameters
t = [start_time:P.resp.dt:end_time]; 
disp('ran')

%% Initial Values
Ppl = 0; %Techically Ppl = -3 at start insp, but we assume the driving pressure creating flow, to be equal to PEEP 
Pao = 0; % %Initial Pao is PEEP [cmH2O], supplied by Pvent 
V = 0; %Initiel Volumen [L] %(P.resp.Crs*P.resp.PEEP)*10^-3;
%flow = 0; %Unnecessary since calculated from pressures
Pmus = 0;
dPmus = 0;
P.resp.breath_cnt = 0 %Housekeeps nr. of breath cycles
PSTrigger = false; %Triggers when PS is activated
Pmus_Cycle = false; %Triggers when Pmus cycles to expiration
%% System of Equations
for i = 1:length(t)
%% PSTrigger state
    % Reset trigger state at beginning of new breath cycle
    if mod(round(t(i),3),round(P.resp.TCT,3)) == 0 && t(i) > 0
        PSTrigger = false; %Reset PSTrigger to initiate breath cycle
        Pmus_Cycle = false; %Reset Pmus breath cycle
        disp('PSTrigger set false')

        %Housekeeps nr. of breath cycles            
        P.resp.breath_cnt = P.resp.breath_cnt + 1;
    end

    % PSTrigger controls delivery of Pvent and Pmus activation
    if Ppl <= P.resp.PSTrigger && PSTrigger == false
        PSTrigger = true;
        P.resp.TriggerTime = t(i)-(P.resp.breath_cnt*P.resp.TCT); %Logs triggertime, normalized for each breath    
        disp(['PVENT TRIGGER SET AT TIME',num2str(P.resp.TriggerTime), 'Ppl is:', num2str(Ppl)])
    end
    
   
    
    %% Pmus Activation    
    % Pmus adds dP caused by patient breathing effort
    Pmus = Pmus_Driver(t(i),Pmus_Cycle);

    if i > 1 
    dPmus = Pmus-P.resp.Pmus(i-1);   
    end

    %% Pvent Activation
    Pvent = Pvent_DriverPS(t(i),PSTrigger); %Pressure delivered by vent at t [cmH2O]

    %Flow is driven by the dP of Pvent-Pmus
    flow=(((Pvent-P.resp.PEEP)-Ppl)/P.resp.R); %[L/s] -> [L/min] at plot
    %In NPV, Ppl 
    flow = flow;



    %flow=(((Pvent)-Ppl)/8) %%% PEEP ACTIVE FOR DEBUGGING

    dV = (flow*P.resp.dt); 
    V = V + dV; %
    
    % dV then creates a dPao, through either in- or deflation
    dPao = dV/(P.resp.Crs*10^-3); %Change in pressure ((L/dt)*dt)/(L/P) =(P/dt)*dt = P
    %dPao = -dPao;
    Pao = Pao+dPao; %NPV change is negative, even when volume is positive
    
    %% Ppl
    %Seperate Ppl section for a cleaner code
    dPpl = (dV/P.resp.Cw)-dPmus; %Pmus = V(t)/Cw-dPpl(t) - Thus Ppl is calculated from Pmus

    if round(abs(dPmus),5) == round(dPmus,5)
        %disp(['Equal at i: ',num2str(i)])
    else
        %disp(['Not equal at i: ',num2str(i), ' difference is:', num2str(round(abs(dPmus),3) - round(dPmus,3))])
    end
    %dPpl = dPpl+dPao; %Add changes from Pao aswell as Pmus
    %disp(['dPpl:',num2str(dPpl)])
    Ppl = Ppl+dPpl; % Calculate Ppl
    Ppl = Ppl + dPao;
    
    
     %% PMusCycle state
     
    %Cycle must be checked after flow has been calculated
    if flow >= P.resp.PmusCycle && Pmus_Cycle == false && i>2 
        Pmus_Cycle = true; %Sets cycle to true, begins Pmus monotonic decrease towards 0
        P.resp.PmusCycleTime = t(i)-(P.resp.breath_cnt*P.resp.TCT); %Records the time at which cycle variable is reached, normalized for breath_cnt
        disp(['PMUS CYCLE TIME AT: ', num2str(P.resp.PmusCycleTime)])
        
        P.resp.Pmus_At_CV = Pmus;
        disp(num2str(Pmus));
    end
    


    
    %% Housekeeping
    Housekeep(i,flow,V,Pvent,Pmus,Ppl,Pao);    
end

