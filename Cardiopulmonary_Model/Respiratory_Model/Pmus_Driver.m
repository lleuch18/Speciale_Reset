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
PmusTe = P.resp.PmusTe;
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
%t = round(t-(P.resp.SBT_cnt*SBT_lgth),3);


%Checks if t has reached end of SBT cycle, and increases SBT_cnt if yes
if mod(t,SBT_lgth) == 0 && t>0     
    P.resp.SBT_cnt = P.resp.SBT_cnt + 1;
    disp(['SBT_cnt: ',num2str(P.resp.SBT_cnt)])
end

t=round(t-P.resp.SBT_cnt*SBT_lgth,3);





%% Assign Pmus based on time 
if Pmus_Cycle    
    %Subtract TriggerTime, in order to access Pmus_Exp at its origin
    t = t-P.resp.PmusCycleTime;   
    
    if t<=PmusTe

        %Acceses the pre-calculated Pmus at expiration, at index
        %corresponding to current time
    Pmus = P.resp.Pmus_Exp_PSTrigger(find(abs(P.resp.t_exp-t)<0.001));
    else
        Pmus=0;
    end

else
    
    if t >= Tstart && t <= round(PmusTi,3) %Monotonically increase during inspiration
        Pmus = PmusSet*sin((pi/(2*PmusTi))*t);
        %disp(['Pmus ', num2str(Pmus), 'At t', num2str(t)])
    elseif t > PmusTi && t <= round(PmusTi+PmusTe,3)  %Monotonically decrease during expiration
        t = t-PmusTi; %Subtract PmusTi, to normalize time from PmusTe point of view        
        Pmus = P.resp.Pmus_Exp_NoTrigger(find(abs(P.resp.t_exp-t)<0.001));

    elseif t > PmusTe+PmusTi && t <= PmusTe+PmusTi+PmusPause % 0 During pause between insp and exp
        Pmus = 0;
    end
end
end


