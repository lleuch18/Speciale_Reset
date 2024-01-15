%% Previous Chunk Shift Mechanism
for ib = 1:length(timeframes)
        if  ~isempty(find(abs(timechunk{timeframes(ib)}-round(start/100,3))<0.001))
            chunk = timeframes(ib);  
            breath_norm = b_i-1; %Normalizes breath according to breathnr in NBPdata
        end
    end

%% NBPData used as breath indexer
sp time = insp_length
% Breath length = TCT
    
 
    for b_i = 1:length(NBPdata{ia})
        breath = b_i;
        P.resp.cnt = P.resp.cnt+1;
        %Threepoint method for detecting insp_length, exp_length and
        %b_length|| b_i+2 <= length(nd3{chunk})

      
        %b>b+1
        if NBPdata{ia}(b_i,1)>NBPdata{ia}(b_i+1,1) && b_i+1 <= length(nd3{chunk}) 
            disp('activated condition 1')
            start = NBPdata{ia}(b_i-2,5)*100;
            midpeak = NBPdata{ia}(b_i-1,5)*100;
            endpeak = NBPdata{ia}(b_i,5)*100;

        %b+1>b+2
        elseif  b_i+1 <= length(nd3{chunk}) && b_i+2 <= length(nd3{chunk}) && NBPdata{ia}(b_i+1,1)>NBPdata{ia}(b_i+2)
            disp('activated condition 2')
            start = NBPdata{ia}(b_i-1,5)*100;
            midpeak = NBPdata{ia}(b_i,5)*100;
            endpeak = NBPdata{ia}(b_i+1,5)*100;       
            disp(['Start: ',num2str(start),'  mid: ',num2str(midpeak),'  end:  ',num2str(endpeak)])
%{
        %b+1<b+2    
        elseif b_i-1>=1 && b_i+2 <= length(nd3{chunk}) && NBPdata{ia}(b_i+1,1)<NBPdata{ia}(b_i+2)
            disp('activated condition 3')
            start = NBPdata{ia}(b_i-1,5)*100;
            midpeak = NBPdata{ia}(b_i,5)*100;
            endpeak = NBPdata{ia}(b_i+1,5)*100;
%}

            %b+1<b+2
        elseif b_i-1>=1 && b_i-2 >= 1 && b_i+1 <= length(nd3{chunk}) && b_i+2 <= length(nd3{chunk}) && NBPdata{ia}(b_i)+1 < NBPdata{ia}(b_i+2)
            disp('activated condition 4')
                start = NBPdata{ia}(b_i-2,5)*100;
                midpeak = NBPdata{ia}(b_i-1,5)*100;
                endpeak = NBPdata{ia}(b_i,5)*100;

        elseif b_i-1>=1 && b_i-2 >= 1
            disp('activated condition 5')
            start = NBPdata{ia}(b_i-2,5)*100;
            midpeak = NBPdata{ia}(b_i-1,5)*100;
            endpeak = NBPdata{ia}(b_i,5)*100;

        else
            disp('activated condition 6')
            start = NBPdata{ia}(b_i,5)*100;
            midpeak = NBPdata{ia}(b_i+1,5)*100;
            endpeak = NBPdata{ia}(b_i+2,5)*100;

        end
    

        %b_start = NBPdata{ia}(breath,5);
        %b_end = NBPdata{ia}(breath+1,5);

        %Check which timechunk breath belongs to, by checking which
        %chunk start time is logged in
        
        for ib = 1:length(timeframes)
            if  ~isempty(find(abs(timechunk{timeframes(ib)}-round(start/100,3))<0.001))
                chunk = timeframes(ib);  
                breath_norm = b_i-1; %Normalizes breath according to breathnr in NBPdata
            end
        end
            
            %Normalize indexes with respect to current timechunk
            if chunk > 1 || (ia >= 1 && chunk>1)
                disp('Activated Special Condition')
                start = start-(timechunk{chunk}(1)*100);
                midpeak = midpeak-(timechunk{chunk}(1)*100);
                endpeak = endpeak-(timechunk{chunk}(1)*100);
                %Normalize breath with respect to index
                breath = breath-breath_norm;                
            end

       
           min_start_mid = find(flowchunk{chunk}(start:midpeak)-min(flowchunk{chunk}(start:midpeak))<0.001)+start;
           min_mid_end = find(flowchunk{chunk}(midpeak:endpeak)-min(flowchunk{chunk}(midpeak:endpeak))<0.00001)+midpeak;
            
           %insp_length found by all positive flow values above threshold between minimums
           insp_length = length(find(flowchunk{chunk}(min_start_mid(1):min_mid_end(1))>36)); % [36mL/s] chosen as arbitrary threshold through visual analysis, to filter faux-inspirations and minimal loss.
           %exp_length found by all negative values between two peaks
           exp_length = length(find(flowchunk{chunk}(midpeak:endpeak)<-8));

           b_length = insp_length+exp_length;
        

         
        
            
        %% 2. Extract PPV data at filtered breath timeframes 
        d3 = nd3{chunk}(breath); %d3=maxinsp-minexp
        d4 = nd4{chunk}(breath); %d4=mininsp-maxexp

        %% 3. Extract Pmus parameter at breath
        P.resp.PmusSet = pmus{chunk}(breath);
        %% 4. Extract Ceff
        P.resp.Crs = NBPdata{ia}(b_i,8);
        %% 5. Input Raw 
        P.resp.R = best_raw*10000;        
        
        %% 6. Run cardiopulmonary model at breath
        % 6a Run respiratory Model at breath
        %Vent Settings
        P.resp.PS = NBPdata{ia}(b_i,7);
        P.resp.PEEP = NBPdata{ia}(b_i,4)-NBPdata{ia}(b_i,7);
        P.resp.Ti = insp_length/100; %Inspiration time as insp_length
        P.resp.Te = exp_length/100; % -||- 
        P.resp.TCT = b_length/100; %Total Cycle Time in seconds
        P.resp.Trise = P.resp.Ti*0.2; % 20percent of Ti        
        
        %Pmus settings
        P.resp.PmusTi = insp_length/100; %Inspiratory time of Pmus [s]
        P.resp.PmusTe = exp_length/100; %Expiratory time of Pmus [s]       
        
        %Run Model
        Respiratory_Modelfn_PS(P.resp.Ppl0,0,P.resp.TCT,b_i)     
        
        %Reset P.resp.fields to ready for new breath
        if isfield(P.resp, 'Pmus_Exp_PSTrigger') == 1     
        P.resp=rmfield(P.resp,'Pmus_Exp_PSTrigger');
        end  

        if isfield(P.resp, 'Pmus_Exp_NoTrigger') == 1   
        P.resp=rmfield(P.resp,'Pmus_Exp_NoTrigger');
        end
            
        % 6b Run Intrathoracic Model at breath
        end
    end 

    




%6. Compare Simulated vs. measured PPV at timeframes


%7. Compute loss



%8. Conclude on hypothesis


%%
test = find(flowchunk{1}(round(14.8,3)*100:round(18.3,3)*100)>36);
test2 = flowchunk{1}(test);
plot(test2)
%%

%% Out of bounds conditionals
if (NBPdata{ia}(b_i,1)>NBPdata{ia}(b_i+1,1)) == 1 || b_i+1 <= length(NBPdata{ia}) && b_i - 2 >= 1 && b_i - 1 >= 1
     disp('activated condition 1')
            start = NBPdata{ia}(b_i-2,5)*100;
            midpeak = NBPdata{ia}(b_i-1,5)*100;
            endpeak = NBPdata{ia}(b_i,5)*100;
        elseif NBPdata{ia}(b_i+1,1)>NBPdata{ia}(b_i+2)
            disp('activated condition 2')
            start = NBPdata{ia}(b_i-1,5)*100;
            midpeak = NBPdata{ia}(b_i,5)*100;
            endpeak = NBPdata{ia}(b_i+1,5)*100;
        
        elseif xor(b_i+1 > length(NBPdata{ia}),b_i+2 > length(NBPdata{ia}))
            disp('activated condition 3')
                start = NBPdata{ia}(b_i-2,5)*100;
                midpeak = NBPdata{ia}(b_i-1,5)*100;
                endpeak = NBPdata{ia}(b_i,5)*100;
                disp(['Start: ',num2str(start),'  mid: ',num2str(midpeak),'  end:  ',num2str(endpeak)])
        else

%% Create Pmus_Exp profile if it doesn't exist
if isfield(P.resp, 't_exp') == 0 && Pmus_Cycle == true
    %disp(['value of exist(): ', num2str(isfield(P.resp, 'Pmus_Exp_PSTrigger'))])
    %Creates a pre-calculated version of Pmus at expiration, which is the
    %inverse of inspiratory Pmus, with a frequency defined by PmusTe
    %instead of PmusTi
    P.resp.t_exp = [0:P.resp.dt:PmusTe]';   
    P.resp.Pmus_Exp_PSTrigger = P.resp.Pmus_At_CV*sin((pi/(2*PmusTe))*P.resp.t_exp); P.resp.Pmus_Exp_PSTrigger = P.resp.Pmus_Exp_PSTrigger(end:-1:1);
end

%Compute the same expiratory profile, at situations where CV is never
%active
if isfield(P.resp, 't_exp') == 0    
    P.resp.t_exp = [0:P.resp.dt:PmusTe]';
    P.resp.Pmus_Exp_NoTrigger = P.resp.PmusSet*sin((pi/(2*PmusTe))*P.resp.t_exp); P.resp.Pmus_Exp_NoTrigger = P.resp.Pmus_Exp_NoTrigger(end:-1:1);
end

%% Pmus_Driver before integration with P&V Framework
function Pmus = Pmus_Driver(t,Pmus_Cycle)
%PMUS_DRIVER Outputs Pmus at current time, given that conditions of
%spontaneous breathing are met, and PS trigger hasn't been reached

global P

%% Pre-define variables for cleaner code
PS = P.resp.PS;
%PEEP = P.resp.PEEP;
Trise = P.resp.Trise;
Tdeflate = P.resp.Tdeflate;
PmusTi = P.resp.PmusTi;
PmusTe = P.resp.PmusExpLgth;
PmusPause = P.resp.TCT-PmusTi-PmusTe; %Ensures that SBT lgth & PS lgth are equal - based on TCT

Tstart = 0;
PmusSet = P.resp.PmusSet; 

%% Create Pmus_Exp profile if it doesn't exist
if isfield(P.resp, 'Pmus_Exp_PSTrigger') == 0 && Pmus_Cycle == true
    %disp(['value of exist(): ', num2str(isfield(P.resp, 'Pmus_Exp_PSTrigger'))])
    %Creates a pre-calculated version of Pmus at expiration, which is the
    %inverse of inspiratory Pmus, with a frequency defined by PmusTe
    %instead of PmusTi
    P.resp.t_exp = [0:P.resp.dt:PmusTe]';   
    P.resp.Pmus_Exp_PSTrigger = P.resp.Pmus_At_CV*sin((pi/(2*PmusTe))*P.resp.t_exp); P.resp.Pmus_Exp_PSTrigger = P.resp.Pmus_Exp_PSTrigger(end:-1:1);
end

%Compute the same expiratory profile, at situations where CV is never
%active
if isfield(P.resp, 'Pmus_Exp_NoTrigger') == 0    
    P.resp.t_exp = [0:P.resp.dt:PmusTe]';
    P.resp.Pmus_Exp_NoTrigger = P.resp.PmusSet*sin((pi/(2*PmusTe))*P.resp.t_exp); P.resp.Pmus_Exp_NoTrigger = P.resp.Pmus_Exp_NoTrigger(end:-1:1);
end
%% Decouple Spontaneous Breathing from Simulation Time
% Set total SBT cycle length
SBT_lgth = round(PmusTi+PmusTe+PmusPause,3); %Round() Necessary for float-point comparison in mod(t,SBT_lgth)


%Creates SBT_cnt if it doesn't exist
if isfield(P.resp,'SBT_cnt') == 0 
     P.resp.SBT_cnt = 0;     
end

% Ensure that t is between 0 and SBT_lgth
t = round(t-(P.resp.SBT_cnt*SBT_lgth),3);


%Checks if t has reached end of SBT cycle, and increases SBT_cnt if yes
if mod(t,SBT_lgth) == 0 && t>0     
    P.resp.SBT_cnt = P.resp.SBT_cnt + 1;
    disp(['SBT_cnt: ',num2str(P.resp.SBT_cnt)])
end





%% Assign Pmus based on time 
if Pmus_Cycle    
    %Subtract TriggerTime, in order to access Pmus_Exp at its origin
    t = t-P.resp.PmusCycleTime;   
    
    if t<=PmusTe
        if t < 0.006
            %t
        end
        %Acceses the pre-calculated Pmus at expiration, at index
        %corresponding to current time
    Pmus = P.resp.Pmus_Exp_PSTrigger(find(abs(P.resp.t_exp-t)<0.001));
    else
        Pmus=0;
    end

else
    
    if t >= Tstart && t <= PmusTi %Monotonically increase during inspiration
        Pmus = PmusSet*sin((pi/(2*PmusTi))*t);
        %disp(['Pmus ', num2str(Pmus), 'At t', num2str(t)])
    elseif t > PmusTi && t <= PmusTi+PmusTe  %Monotonically decrease during expiration
        t = t-PmusTi; %Subtract PmusTi, to normalize time from PmusTe point of view
        %Pmus = -PmusSet*sin((pi*(t+PmusTe-2*PmusTi))/(2*(PmusTe-PmusTi)));
        Pmus = P.resp.Pmus_Exp_NoTrigger(find(abs(P.resp.t_exp-t)<0.001));
    elseif t > PmusTe+PmusTi && t <= PmusTe+PmusTi+PmusPause % 0 During pause between insp and exp
        Pmus = 0;
    end
end
end




%% Pmus_Driver when PSTrigger was cycle variable
function Pmus = Pmus_Driver(t,PSTrigger)
%PMUS_DRIVER Outputs Pmus at current time, given that conditions of
%spontaneous breathing are met, and PS trigger hasn't been reached

global P

PS = P.resp.PS;
PEEP = P.resp.PEEP;
Trise = P.resp.Trise;
Tdeflate = P.resp.Tdeflate;
PmusTi = P.resp.PmusTi;
PmusTe = P.resp.PmusExpLgth;
PmusPause = P.resp.PmusPause;
PmusExpLgth = P.resp.PmusExpLgth;
Tstart = 0;
PmusSet = P.resp.PmusSet; 



if isfield(P.resp, 'Pmus_Exp_PSTrigger') == 0
    disp(['value of exist(): ', num2str(isfield(P.resp, 'Pmus_Exp_PSTrigger'))])
    %Creates a pre-calculated version of Pmus at expiration, which is the
    %inverse of inspiratory Pmus, with a frequency defined by PmusTe
    %instead of PmusTi
    P.resp.t_exp = [0:P.resp.dt:PmusTe]';   
    P.resp.Pmus_Exp_PSTrigger = P.resp.PSTrigger*sin((pi/(2*PmusTe))*P.resp.t_exp); P.resp.Pmus_Exp_PSTrigger = P.resp.Pmus_Exp_PSTrigger(end:-1:1);
    
end

if PSTrigger    
    %Subtract TriggerTime, in order to access Pmus_Exp at its origin
    t = t-P.resp.TriggerTime

    disp(['t_exp:',num2str(find(abs(P.resp.t_exp-t)<0.001))])
    if t<=PmusTe
        %Acceses the pre-calculated Pmus at expiration, at index
        %corresponding to current time
    Pmus = P.resp.Pmus_Exp_PSTrigger(find(abs(P.resp.t_exp-t)<0.001))
    else
        Pmus=0;
    end
else
    if t >= Tstart && t <= PmusTi %Monotonically increase during inspiration
        Pmus = PmusSet*sin((pi/(2*PmusTi))*t);
        %disp(['Pmus ', num2str(Pmus), 'At t', num2str(t)])
    elseif t > PmusTi && t <= PmusTi+PmusTe  %Monotonically decrease during expiration
        t = t-PmusTi; 
        Pmus = -PmusSet*sin((pi*(t+PmusTe-2*PmusTi))/(2*(PmusTe-PmusTi)));
    elseif t > PmusTe-PmusTi && t <= PmusTe-PmusTi+PmusPause % 0 During pause between insp and exp
        Pmus = 0;
    end
end
end

%% Debugging Variables in RespModel
%%%%%Time
%{
    if mod(round(t(i),3),round(0.1,3)) == 0
        disp(['current t is:', num2str(t(i))])
    end
    %}

    %disp(['Function ran at t:',num2str(t(i))])

%%%%%Pmus
 %  if Pmus > -1.5
       %{  disp(['t:', num2str(t(i))]);
        %disp(['dpmus:', num2str(dPmus)]);
        %disp(['Pmus:', num2str(Pmus)]);
        %disp(['Pmus(i-1)',num2str(P.resp.Pmus(i-1))]); 
    %end 


%%%%%Pvent
%{
    if t(i)>0 && t(i)<0.5
    disp(['t:', num2str(t(i))]);
        disp(['Pvent:', num2str(Pvent)]);
        disp(['Ppl:', num2str(Ppl)]);
        disp(['Flow',num2str(flow)]);
    end
    %}
    % The flow created by the dP, adds an amount of dV

%% State_Switch
%state = State_Switch(t);
%Unanswered Questions:
%%How to handle phases of breath cycle?
%We set a Ti and Te
%Ti is run at Δt intervals
%When mod(cnt_ti,Ti) = 0, we switch to Te and reset Ti
%Visa Verse when mod(cnt_te,Te) = 0



%% Earlier Versions of PmusDriver
%{disp(['t in PmusDriver: ',num2str(t)])
    %Pmus =  -P.resp.PSTrigger*sin((pi*(t+PmusTe-2*PmusTi))/(2*(PmusTe-PmusTi))); %%%KEEP EYE ON FUNNY INTERACTIONS WHEN PSTRIGGER IS HIT
    %Pmus = Pmus+(PmusSet*sin((pi/(2*PmusTi))*P.resp.TriggerTime)+P.resp.PSTrigger*sin((pi*((P.resp.TriggerTime+0.02)+PmusTe-2*PmusTi))/(2*(PmusTe-PmusTi))));
    

%% Original Driver Function
%if state == 'insp'
%Pao calc from Trise and Ti
%Pao = Activation_Function(tDummy);

%% Test Start/End time
pao = P.(var_name).pao(PSstart(1):PSend(1));
plot(pao);
hold on

for i = 1:length(P.(var_name).insp1)
%plot(pao(P.(var_name).insp1(i)))
text(P.(var_name).insp1(i),pao(P.(var_name).insp1(i)),strcat('insp',num2str(i)))
hold on
text(P.(var_name).exp1(i),pao(P.(var_name).exp1(i+1)),strcat('exp',num2str(i)))
end




%% Inspiratory/Expiratory time

%PSStart and PSEnd provide timeframes in which a certain PS level is set on
%the patients ventilator
for i = 1:length(PSstart)
    i_str = num2str(i);
    [insp,exp] = start_ie2(P.(var_name).flow(PSstart(i):PSend(i))); %Extracts inspiratory and expiratory time for the batch given to the function
    temp_str_insp = strcat('insp',i_str);
    P.(var_name).(temp_str_insp) = insp;
    temp_str_exp = strcat('exp',i_str);
    P.(var_name).(temp_str_exp) = exp;    
end

%% Extract Patient Specific Characteristics

[PSstart,PSend] = extract_chuncks(patient_nr,var_name); 
%Time in seconds converted to sample rate of 100Hz
PSstart = PSstart*100;
PSend = PSend*100;

%start_ie2(P.(var_name).flow)


%% Index_Mapping
index = find(P.resp.index_mapping==t); %Find the index which hold the given time_point
disp(['Current time: ', num2str(t)])
disp(['Current Pao: ', num2str(P.resp.Pao(index))])
disp(['Current Index: ', num2str(index)])


%% Flow Conditionals
 %{
    if t(i) == 0
        flow = 0;
    else    
    flow=(Pao-Ppl)/P.resp.R; %1. Calculate flow at each timestep 
    %Normal Resistance 2 to 3 cmH2O/L/sec.
    end

    %if t(i)>P.resp.Ti && t(i)<= P.resp.Ti+P.resp.Te
      %  flow = flow*-1;
    %end
 %}

%% Initial Ppl
%Ppl0 = Ppl0+P.resp.PEEP; %Default -3cmH2O + PEEP
%Ppl = Ppl0; %Set by user



%% PSModel with Pmus Dominance
function Respiratory_Modelfn(Ppl0,start_time,end_time)
%Computes the system of equations governing the equation of motion as a
%continious time derivative, controlled by driver function Pao
%   Detailed explanation goes here

global P
%% Plots
[Pao_plot,Ppl_plot,flow_plot,V_plot,Pvent_plot,Pmus_plot] = plots(1,1,1,1,1,1);

plot = false %Switch on/off for all plots

%% Loop Parameters
t = [start_time:P.resp.dt:end_time]; 


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
    if Pmus <= P.resp.PSTrigger && PSTrigger == false
        PSTrigger = true;
        P.resp.TriggerTime = t(i)-(P.resp.breath_cnt*P.resp.TCT); %Logs triggertime, normalized for each breath    
        disp(['PVENT TRIGGER SET AT TIME',num2str(P.resp.TriggerTime), 'Pmus is:', num2str(Pmus)])
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
    flow=(((Pvent-P.resp.PEEP)-Ppl)/8); %[L/s] -> [L/min] at plot
    %flow=(((Pvent)-Ppl)/8) %%% PEEP ACTIVE FOR DEBUGGING

    dV = (flow*P.resp.dt); 
    V = V + dV; %
    
    % dV then creates a dPao, through either in- or deflation
    dPao = dV/(P.resp.Crs*10^-3); %Change in pressure ((L/dt)*dt)/(L/P) =(P/dt)*dt = P
    Pao = Pao+dPao;
    
    %% Ppl
    %Seperate Ppl section for a cleaner code
    dPpl = dPmus + dPao;
    %disp(['dPpl:',num2str(dPpl)])
    Ppl = Ppl+dPpl; % Calculate Ppl
    
    
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

disp('Simulation Done')

if plot
    
    if Pvent_plot
    figure(1)
    plot(t,P.resp.Pao)
    title('Pao')
    ylabel('Pao (cmH2O)')
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
    plot(t,P.resp.flow);%*60 for debugging purpose
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
    %yticks([0,0.5,1,1.5,2,2.5,3,3.5,4])
    %yline((P.resp.CL*P.resp.PEEP)*10^-3)
    end
    
    if Pvent_plot
    figure(5)
    plot(t,P.resp.Pvent)
    title('Pvent')
    ylabel('P (cmH2O)')
    xlabel('Time (S)')
    end
    
    if Pmus_plot
    figure(6)
    plot(t,P.resp.Pmus)
    title('Pmus')
    ylabel('P (cmH2O)')
    xlabel('Time (S)')
    end
end



end

