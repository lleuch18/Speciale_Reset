function Housekeep(t, flow,V,Pvent,Pmus,Ppl,Pao)%Palv,
          
global P

%Allocate memory for breathlog, to increase performance
%Allows for only new breaths to be logged

%HOUSEKEEP saves results of state variables at each timestep
%   Appends the values calculated by the ODE solver at each timestep, to a
%   data structure for analysis purposes
%if mod(t,50) == 0
%disp(['Ran Housekeep at ',num2str(breath)])
%end

%flow = 1; V = 2; Pvent = 3; Pmus = 4; Ppl = 5; Pao = 6;
P.resp.flow(t) = flow;
P.resp.V(t) = V;
P.resp.Pvent(t) = Pvent;
P.resp.Pmus(t) = Pmus;
P.resp.Ppl(t) = Ppl;
P.resp.Pao(t) = Pao;


end

