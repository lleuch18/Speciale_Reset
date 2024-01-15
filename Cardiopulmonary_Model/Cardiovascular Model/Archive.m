 %if breaths are logged inconsistently, length of each breath
        %becomes average lgth between them, i.e.:
        %same extraction method as below, with insp_ & exp_length being the
        %average over amt_breaths
        %{
            % if NBPdata{ia}(breath+1,1)-NBPdata{ia}(breath,1) >1
            amt_breaths = NBPdata{ia}(breath+1,1)-NBPdata{ia}(breath,1);            

            min_start_mid = find(flowchunk{chunk}(start:midpeak)-min(flowchunk{chunk}(start:midpeak))<0.001)+start;
            min_mid_end = find(flowchunk{chunk}(midpeak:endpeak)-min(flowchunk{chunk}(midpeak:endpeak))<0.001)+midpeak;
            
            insp_length = length(find(flowchunk{chunk}(min_start_mid(1):min_mid_end(1))>36))/amt_breaths;
            exp_length = length(find(flowchunk{chunk}(midpeak:endpeak)<-20))/amt_breaths;

            b_length = insp_length+exp_length/amt_breaths;        
        
        else 
        %}

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
    disp(' ')
    disp(['t= ',num2str(P.t(end)),';  Time to go= ',...
        num2str(P.General.tEnd-P.t(end))]); pause(0.01);
    
    tol=1e-4; %tol= 1e-4 or 1e-5: trade off accuracy and calculation speed
    opt = odeset('RelTol',tol,'AbsTol',tol);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Beregn Ppl for respiratorisk cyclus
    [Ppl_insp,Ppl_exp] = Ppl(P.General.Insp_Time,P.General.Exp_Time,-3,-10)

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






%%%%%%%%%%%%%%%%%%%%
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
P.General.Insp_Time = 1.5;
P.General.Exp_Time = 2.5;


%%%%%%%%How is this while loop updated?
%While loop is updated in line 68 of Adapt0P
%Adapt0P is called in line 71 of CircAdaptP
while P.t(end)<P.General.tEnd-Dt;
    TimingP; % 
    PutFt('ArtVen','q0AV','Syst',P.General.q0);% Systemic flow

    % Set simulation interval
    %nDt= round(P.General.tCycle/P.General.Dt+1); % number of time points    
    nDt= round(P.General.tCycle/(10*Dt)+1); %Changed to 1/10th time interval for optimization

    TimePoints= P.General.tCycle*(0:nDt)/nDt; %ODE solver intervals as a fraction of total time steps
    disp(['TimePoints',num2str(TimePoints)])
    % existing solution
    disp(' ')
    disp(['t= ',num2str(P.t(end)),';  Time to go= ',...
        num2str(P.General.tEnd-P.t(end))]); pause(0.01);
    
    tol=1e-4; %tol= 1e-4 or 1e-5: trade off accuracy and calculation speed
    opt = odeset('RelTol',tol,'AbsTol',tol);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Beregn Ppl for respiratorisk cyclus
    %[Ppl_insp,Ppl_exp] = Ppl(P.General.Insp_Time,P.General.Exp_Time,-3,-10);

    %Tilføj Ppl for respiratoriske cyclus til de relevante variabler
    cnt=0
    while cnt<=10;
        cnt = cnt+1; %Increase cycle cnt
        i_start = cnt*1;
        i_end = cnt*10;
    %Her beregnes 1 hjerteslag (eller 1/10 alt efter setting)
    [tDummy,SVarAppend]= ode113('SVarDot',...
        TimePoints(1,i_start:i_end),P.SVar(end,:),opt); % solving of Differential Equations
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SVar= [SVar(1:end-1,:);SVarAppend(1:end,:)]; %appends 1-beat SVar-vector
    % SVar(end,:) removed because of overlap with next beat
    P.SVar= SVarAppend(:,1:end);
    %CircDisplayP; % display and time course of 1-beat hemodynamics
    % Calculation of changes due to adaptation
    feval(P.Adapt.FunctionName); % Execute AdaptXX
    % Time courses in Par belong to parameter setting before Adapt-action!
    end
    

    
end

P.SVar= SVar; %state variables of all beats to show trends. Be careful,
% because AdaptXX has been applied, the Par-parameters do not belong to the
% Par.SVar. Only for Adapt0 (= no adaptation), complete SVar
% is compatible with parameter settings.
end

%%%Parameters
R = 2; %Resistance CmH2Os/Liter
C_al = 0.033; %Alveolar Compliance V/P
C_Lungs = 40 %%%%%%PATIENT SPECIFIC%%%%%%%%
Va(1) = 3; %Initiel volumen 3L
Pa(1) = 5; %Initielt alveolært tryk 5CmH2O (PEEP)
Pinsp = 20; %Leveret Tryk



%Flow 
%Q = Pvent-Pal/R
flow=(Pinsp-Pa)/R; %Calculate flow at each timestep
dPa = (flow*timestep)/C; %Change in pressure (L/Timestep)/(L/P) =P/Timestep
Pa = Pa+dPa;


%Volume
Vdt = flow*timestep %Volume is flow over time
V=V+Vdt;


%%%Pao
%Pao = RQ+EV+PEEP
Pao = R*flow+(1/C)*V+PEEP;





%3. Calculate Flow
    %Q = Pao-Palv/R
    flow=(Pao-Palv)/R; %Calculate flow at each timestep
    %4. Calculate Palv
    dPa = (flow*dT)/C; %Change in pressure (L/Timestep)/(L/P) =P/Timestep*TimeStep
    Palv = Palv+dPalv;
    %5. Calculate Volume
    dV = flow*dT %Volume is flow over time
    V=V+dV;
    %6. Calculate Pao
    dPao = R*flow+(1/C)*V;
    Pao = Pao + dPao;
    %7. Calculate Ppl



