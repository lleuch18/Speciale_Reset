function Pvent = Pvent_DriverPC(t,PSTrigger)
global P
%disp('ran')
%ACTIVATION_FUNCTION Function which simulates the delivered pressure from
%the ventilator
%   Ti: Inspiratory time
%   Trise: Rise time, 20% of Ti
%   Te: Expiratory time
%   Tdeflate: Expiratory Time Constant
PS = round(P.resp.PS,3);
PEEP = round(P.resp.PEEP,3);
Trise = round(P.resp.Trise,3);
Tdeflate = round(P.resp.Tdeflate,3);
Ti = round(P.resp.Ti,3);
Te = round(P.resp.Te,3);




%% Decouple Pvent from Simulation Time
TCT = round(P.resp.TCT,3); %Reduce Verboseness (reduced performance is negligible)

%Creates TCT_cnt if it doesn't exist
if isfield(P.resp,'TCT_cnt') == 0
     disp('TCT SET')
     P.resp.TCT_cnt = 0;     
end

% Ensure that t is between 0 and SBT_lgth
t = round(t-P.resp.TCT_cnt*TCT,3);

if t <0.1
    %disp(['t from Pvent perspective: ', num2str(t)])
end

%Checks if t has reached end of SBT cycle, and increases SBT_cnt if yes
if mod(t,TCT) == 0 && t>0     
    P.resp.TCT_cnt = P.resp.TCT_cnt + 1;
    disp(['TCT_cnt: ',num2str(P.resp.TCT_cnt)])
end

if mod(round(t,3),round(0.1,3)) == 0
        %disp(['current t at Pvent  is:', num2str(t)])
end

if PSTrigger
    t = round(t-P.resp.TriggerTime,3);    

    if mod(round(t,3),round(0.1,3)) == 0
        %disp(['t at PSTrigger is', num2str(t)])
    end
    
    if t >= 0 && t <= Trise %Smoothly rise over Trise
        
        Pvent = PS*(t/Trise)+PEEP;
    elseif t > Trise && t <= Ti %Remain constant during insp
        Pvent = PS+PEEP;
    elseif t > Ti && t <= round(Ti+Tdeflate,3) %Smoothly deflate
        t = t-Ti; %Subtract Ti to get elapsed time since exp
        Pvent = PS - (PS*(t/Tdeflate))+PEEP;
    elseif t > round(Ti+Tdeflate,3) && t <= round(Te + Ti,3) %Remain constant during exp
        Pvent = PEEP;
    end
else
    Pvent = PEEP;
end
