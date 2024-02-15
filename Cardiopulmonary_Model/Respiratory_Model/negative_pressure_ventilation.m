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
SBT_lgth = round(P.resp.Ti+P.resp.Te,3);%+P.resp.PmusPause*2
peakflow = 0;
cnt_test = 0;
Random = 0.45:0.001:0.5;
PplBaseline = 0;
%% System of Equations
for i = 1:length(t)
%% PSTrigger state
    % Reset trigger state at beginning of new breath cycle
    if mod(round(t(i),3),round(P.resp.TCT,3)) == 0 && t(i) > 0
        PSTrigger = false; %Reset PSTrigger to initiate breath cycle
        Pmus_Cycle = false; %Reset Pmus breath cycle
        disp('PSTrigger set false')
        peakflow = 0;

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

    

    %% Pvent Activation
    Pvent = Pvent_DriverPS(t(i),PSTrigger); %Pressure delivered by vent at t [cmH2O]
    
    k = 0.00001;
    p=1;
    
    if t(i)-P.resp.SBT_cnt*SBT_lgth<=P.resp.Ti
        %Flow is driven by the dP of Pvent-Pmus
        flow=(((Pvent-P.resp.PEEP)-Ppl)/P.resp.R); %[L/s] -> [L/min] at plot
        flow=flow;

        dV = flow*P.resp.dt; 

        V = V + dV; %

        if i > 1 
        dPmus = Pmus-P.resp.Pmus(i-1);
        dPmus = p*dPmus;
        end
        
        dPao = (dV*10^3)/(P.resp.Crs);
        dPao = dPao;
        dPpl = p*dPmus+k*((dV*10^3)/(P.resp.Cw));% %Pmus = V(t)/Cw-dPpl(t) - Thus Ppl is calculated from Pmus
        
        P.resp.dPmus(i) = dPmus;
        P.resp.dPao(i) = dPao;
        P.resp.dPpl(i) = dPpl;
 
       

    elseif t(i)-P.resp.SBT_cnt*SBT_lgth > P.resp.Ti && t(i)-P.resp.SBT_cnt*SBT_lgth <= P.resp.Ti+P.resp.Te%+P.resp.PmusPause+P.resp.PmusPause
        
        flow = (((Pvent-P.resp.PEEP)-Ppl)/P.resp.R);
        

        dV = flow*P.resp.dt; 
        
        V = V + dV; %        

        if i > 1 
            dPmus = Pmus-P.resp.Pmus(i-1);
            dPmus = p*dPmus;
        end
        P.resp.dPmus(i) = dPmus;

        dPao = ((dV*10^3)/(P.resp.Crs));
        dPao = dPao;

        dPpl = p*dPmus+k*((dV*10^3)/(P.resp.Cw));%+; %Pmus = V(t)/Cw-dPpl(t) - Thus Ppl is calculated from Pmus

        P.resp.dPmus(i) = dPmus;
        P.resp.dPao(i) = dPao;
        P.resp.dPpl(i) = dPpl;
        
 
    end

    
    %flow=(((Pvent)-Ppl)/8) %%% PEEP ACTIVE FOR DEBUGGING
    


    
    %dPpl = dPpl+dPao; %Add changes from Pao aswell as Pmus
    %disp(['dPpl:',num2str(dPpl)])
    

    %if Ppl > 0.5
        %Ppl = Random(randi([1,numel(Random)]))
       %Ppl = 0.5*sin((pi/2)+(pi/(2*P.resp.Te))*t(i));
    %else
        Ppl = Ppl+dPpl; % Calculate Ppl 
        %Ppl = Pmus + V*10^3/P.resp.Cw;
    %end
        
    

   % if Ppl > 1
    %    %Ppl = randi([0,1])
     %   Ppl = 1
    %end

    Pao = Pao+dPao; %NPV change is negative, even when volume is positive
    
 
   

    
    %% Housekeeping
    Housekeep(i,flow,V,Pvent,Pmus,Ppl,Pao);    
end


subplot(2,2,1)
plot(P.resp.dPmus)
title('dPmus')
legend(num2str(mean(P.resp.dPmus)))
subplot(2,2,2)
plot(P.resp.dPao)
title('dPao')
legend(num2str(mean(P.resp.dPao)))
subplot(2,2,3)
plot(P.resp.dPpl)
title('dPpl')
legend(num2str(mean(P.resp.dPpl)))
subplot(2,2,4)
plot(P.resp.V)
title('V')
legend(num2str(mean(P.resp.V)))

%k = 0.5
