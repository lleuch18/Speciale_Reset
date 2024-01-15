function err = objective_fn(Start_Ppl,End_Ppl)
%Objective function for calculating the difference in PPV between
%simulation at various parameter settings, and patient data

%patientNr: Patientdata to apply
%params: Parameters to optimize

Global P

P.Optim.Start_Ppl = Start_Ppl;
P.Optim.End_Ppl = End_Ppl;

%%%Algorithm
%Set simulation interval
%2. Calculate Ppl
%3. Add Ppl to P
%4. Run CircAdapt
%5. Add Transmural Pressure to Nodes
%6. Calculate error

% Set simulation interval
nDt= round(P.General.tCycle/P.General.Dt+1); % number of time points




%Calculate Ppl
Ppl = Ppl(P.Optim.Start_Ppl,P.Optim.End_Ppl,nDt); %Create range of Ppl in Dt timesteps, simulating Ppl for the heartbeat

%Add Ppl to P (is added to transmural pressure inside CircAdapt)
P.Optim.Ppl = Ppl;

%Run CircAdapt
CircAdaptP; %generate solution

%Add Transmural Pressure to Nodes
for i = 1:length(P.Node.p)
    P.Node.p(i,1:end) = P.Node.p(i,1:end)+P.Optim.Ppl(i,1) %Stepwise add Calculated Ppl to Node pressure
end

%Calculate Error
tot_err = 0;
var_pat = var(P.Optim.Patient);
for i = 1:length(P.Node.p)
    %Calculate err between PPV of Patient and Model
    err = ((P.Optim.Batch(i)-P.Node.p(i,3))^2)/var_pat %Column 3 is PuArt

    %Calculate tot_error
    tot_err = tot_err+err
end





