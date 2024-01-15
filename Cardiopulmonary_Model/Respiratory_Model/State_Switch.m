function state = State_Switch(t)
global P
%STATE_SWITCH Switches between inspiratory & expiratory states

%   takes current time as input, and checks if current time corresponds
%   to either insp or exp phase, and switches correspondingly
%   P.resp.cnt_insp housekeeps nr. of insp cycles
%   P.resp.cnt_exp housekeeps nr. of exp cycles
%   Returns state

%if statement for 1st cycle
%Counts housekeep number of cycles, assuring correct switching of states
P.resp.cnt_insp = 1;
P.resp.cnt_exp = 1;

Ti = P.resp.Ti %Reduce verboseness
Te = P.resp.Te

if t == P.resp.t0 %At time t0, initate insp
    state = 'insp'
elseif t == Ti & P.resp.cnt_insp == 1 %When time reaches Ti, switch to exp
    state = 'exp';
    P.resp.cnt_insp = P.resp.cnt_insp+1; 
elseif t == Ti + Te & cnt_exp == 1 %When time reaches Ti+Te, switch to insp
    state = 'insp';
    P.resp.cnt_exp = P.resp.cnt_exp+1;
end

%if statement for remaining cycles
if t == Ti*cnt_insp+Te %When time reaches Ti, switch to exp
    state = 'exp';
    P.resp.cnt_insp = P.resp.cnt_insp+1; 
elseif t == (Ti + Te)*P.resp.cnt_exp  %When time reaches Ti+Te, switch to insp
    state = 'insp';
    P.resp.cnt_exp = P.resp.cnt_exp+1;
end
end

