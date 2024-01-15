%Load Patientdata
patNr = 2
patient = load(['..\Data\to Lasse 2023\DataP',num2str(patNr),'PS.mat']);
%Register patient in P
global P
P.Optim.Patient = patient;


%Every Heartbeat is 850ms (default)
%Thus, to synchronize, optimization is done in 850ms batches
tf = 850 %TimeFrame

%Initialize fmincon parameters
%Initial Ppl_start and Ppl_end
x=[-3,10]
A=[1,1]
b = [20,20]

for i = 1:tf:length(patient)-1
    i_start = i;
    i_end = i+tf;
    P.Optim.Batch = patient(i_start:i_end);

    fmincon(@objective_fn,x,A,b)
