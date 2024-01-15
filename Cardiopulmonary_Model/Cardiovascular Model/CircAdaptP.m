function CircAdaptP


global P
P.SVar=[];
P2SVar;
SVar=P.SVar(end,:); P.SVar=SVar; % start condition
% SVar will collect state variables of all beats in the series

Dt= P.General.Dt;
P.Adapt.In=[]; P.Adapt.Out=[]; % reset of storage input/output per beat
P.Adapt.FlowVec=[]; % reset flow instationarity detection
P.General.FacpControl=1; % start value p-control factor

%Intrathoracic Pressure Module
%Sine Wave simulates respiratory cycle

%Integrating respiratory module PseudoCode
%1. Calculate insp/Expiratory time for chunck of time (PS setting time)
%2. Set cycle length as insp_start:exp_end
%3. Solving of Resp_Cycle encapsulates Cardiac_Cycle
%4. Calculate resp_cycle first, add outputs to cardiac_cycle
%5. When cardiac_cycle has run for resp_cycle length, recalculate
%resp_cycle and iterate process


%%%%REMEMBER TO CALCULATE THESE DIRECTLY FROM DATA
P.General.insp_time = 1.5;
P.General.exp_time = 2.5;


%%%%%%%%How is this while loop updated?
%While loop is updated in line 68 of Adapt0P
%Adapt0P is called in line 71 of CircAdaptP
while P.t(end)<P.General.tEnd-Dt;
    TimingP; % 
    PutFt('ArtVen','q0AV','Syst',P.General.q0);% Systemic flow

    % Set simulation interval
    nDt= round(P.General.tCycle/Dt+1); % number of time points    


    TimePoints= P.General.tCycle*(0:nDt)/nDt; %Timepoints starts at 0, goes through nDt. Divided by nDt to get evenly spaced timepoints.
    % existing solution
    disp('')
    disp(['t= ',num2str(P.t(end)),';  Time to go= ',...
        num2str(P.General.tEnd-P.t(end))]); pause(0.01);
    
    tol = 1e-4; %tol= 1e-4 or 1e-5: trade off accuracy and calculation speed
    opt = odeset('RelTol',tol,'AbsTol',tol);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    %Tilføj Ppl for respiratoriske cyclus til de relevante variabler

    %Her beregnes 1 hjerteslag
    [tDummy,SVarAppend]= ode113('SVarDot',...
        TimePoints,P.SVar(end,:),opt); % solving of Differential Equations


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    

    SVar= [SVar(1:end-1,:);SVarAppend(1:end,:)]; %appends 1-beat SVar-vector
    % SVar(end,:) removed because of overlap with next beat
    P.SVar= SVarAppend;
    %CircDisplayP; % display and time course of 1-beat hemodynamics
    % Calculation of changes due to adaptation
    feval(P.Adapt.FunctionName); % Execute AdaptXX
    % Time courses in Par belong to parameter setting before Adapt-action!
end

P.SVar= SVar; %state variables of all beats to show trends. Be careful,
% because AdaptXX has been applied, the Par-parameters do not belong to the
% Par.SVar. Only for Adapt0 (= no adaptation), complete SVar
% is compatible with parameter settings.
end