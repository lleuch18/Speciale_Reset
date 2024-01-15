function Housekeep(t, flow,V,Pvent,Pmus,Ppl,Pao,chunk,breath)%Palv,
          
global P

%Allocate memory for breathlog, to increase performance
%Allows for only new breaths to be logged
if isfield(P.model{breath,chunk},'data') == 0
    P.model{breath,chunk}.data = zeros(length(0:P.resp.dt:P.resp.TCT),1);
end

%HOUSEKEEP saves results of state variables at each timestep
%   Appends the values calculated by the ODE solver at each timestep, to a
%   data structure for analysis purposes
%if mod(t,50) == 0
%disp(['Ran Housekeep at ',num2str(breath)])
%end

%flow = 1; V = 2; Pvent = 3; Pmus = 4; Ppl = 5; Pao = 6;
P.model{breath,chunk}.data(t,1) = flow;
P.model{breath,chunk}.data(t,2) = V;
P.model{breath,chunk}.data(t,3) = Pvent;
P.model{breath,chunk}.data(t,4) = Pmus;
P.model{breath,chunk}.data(t,5) = Ppl;
P.model{breath,chunk}.data(t,6) = Pao;


end

