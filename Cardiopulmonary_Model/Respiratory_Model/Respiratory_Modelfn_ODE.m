function [SvarDot] = Respiratory_Modelfn(t,Svar)
global P

%% Function Header
%Governing Equations
%Q = Pao-Ppl/R
%V = Q*deltaT
%Ppl = Ppl0+dPao 

%Svar0 Cheat Sheet
%Svar0(1) = V0 
%Svar0(2) = flow0
%Svar0(3) = Ppl0

%dYdt(1) = flow; dYdt(2) = V; dYdt(3) = Ppl

%% System of Equation s
Pao = Activation_Function(t);

dYdt(2)=(Pao-Svar(3))/P.resp.R; %1. Calculate flow at each timestep

dYdt(1) = Svar(2)*P.resp.dt; %4. Volume is flow over time
%Svar0(1)=Svar0(1)+dV;

%dPao = Pao-P.resp.PaoPrev;

dYdt(3) = Svar(3)+Pao; %5. Calculate Ppl


%% Outputs
disp(['Current Pao: ', num2str(Pao)])

%disp(['Current V: ', num2str(Svar(1))])
%disp(['Current flow: ', num2str(Svar(2))])
disp(['Current Ppl: ', num2str(Svar(3))])

%P.resp.PaoPrev = Pao;

SvarDot = [Svar(1),Svar(2),Svar(3)];
SvarDot = SvarDot';
end

%% To Do's
%%%%%%%%%%%%%%TO DO%%%%%%%%%

%1. Calibrate Parameters
%%%%Do Last



%2. Input Settings
%%%%Do Last



%%%%Pressure Support

















