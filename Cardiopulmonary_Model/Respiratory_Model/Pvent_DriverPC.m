function Pvent = Pvent_DriverPC(t,PSTrigger)
global P
%ACTIVATION_FUNCTION Function which simulates the delivered pressure from
%the ventilator
%   Ti: Inspiratory time
%   Trise: Rise time, 20% of Ti
%   Te: Expiratory time
%   Tdeflate: Expiratory Time Constant
PS = P.resp.PS;
PEEP = P.resp.PEEP;
Trise = P.resp.Trise;
Tdeflate = P.resp.Tdeflate;
Ti = P.resp.Ti;
Te = P.resp.Te;


if t >= 0 && t <= 0.01 %Baseline for 0.01S
    Pvent = 0 + PEEP;
elseif t > 0.01 && t <= Trise %Smoothly rise over Trise
    Pvent = PS*(t/Trise)+PEEP;
elseif t > Trise && t <= Ti %Remain constant during insp
    Pvent = PS+PEEP;
elseif t > Ti && t <= Ti+Tdeflate; %Smoothly deflate
    t = t-Ti; %Subtract Ti to get elapsed time since exp
    Pvent = PS - (PS*(t/Tdeflate))+PEEP;
elseif t > Ti+Tdeflate && t <= Te + Ti; %Remain constant during exp
    Pvent = PEEP;
end

end
