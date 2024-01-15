function [PSstarttime,PSendtime] = extract_chunks(patno,var_name)
global P


Data = P.(var_name).Data;

T0=Data(1,1);
NDATA=size(Data,1);
timepre= (Data(:,1)-T0); % time in seconds starting in 0
flowpre= -Data(:,5);
airpresspre= zeros(NDATA,1);
artpresspre=Data(:,8);
% % % % for patient 2
% %If sys to diastol is less than 40 or greater than 80
if patno==2
    NDATA=828800;   % after this value flow and PAW are NaN
    timepre= (Data(1:NDATA,1)-T0); % time in seconds starting in 0
    flowpre= -Data(1:NDATA,5);
    airpresspre= zeros(NDATA,1);
    artpresspre=Data(1:NDATA,8);
     minvar=35;
     maxvar=80;
     %If BPgreater than 140 or less than 50
     maxval= 140;
     minval =45;
     %limt  for identifying maximum systolic
     maxlimpt=90;
    % %  % PS setings for patient 2
    %PSlevel= [20 15 12 10 8 5 4 20];
    PSlevel= ([25.1 20.1 17.1 15.1 13.1 10.1 9.1 25.2])-7;
    PEEP=7;
    syncFP1=8;
    syncFP2=14;
    PSstarttime=[4.0035e+04 4.045e+04 4.290e+04 4.381e+04 4.487e+04 4.577e+04 4.671e+04 4.761e+04];
    PSendtime=[4.045e+04 4.290e+04 4.381e+04 4.487e+04 4.577e+04 4.671e+04 4.761e+04 4.831e+04];
end

if patno==3
     % %  % PS setings for patient 3
    PSlevel= ([22.1 26.1 25.1 24.1 26.2 28.1])-9;
    PEEP=9;
    syncFP=13;
    PSstarttime=[5.6948e+04 5.7477e+04 5.8338e+04 6.0720e+04 6.1755e+04 6.2661e+04];
    PSendtime=[5.7477e+04 5.8338e+04 6.0720e+04 6.1755e+04 6.2661e+04 6.5131e+04];
end
 

% % for patient 4 - DATA IS already SYNCRONISED 
if patno==4
    minvar=20;
    maxvar=100;
    syncFP1=109;
    syncFP2=12;
    %If BPgreater than 140 or less than 50
    maxval= 150;
    minval =30;
    maxlimpt=90;
    PSlevel= ([22.1 21.1 19.1 17.1 15.1 13.1 11.1 22.2])-7;
    PEEP=7;
    PSstarttime=[4.7628e+04 4.8766e+04 5.1236e+04 5.2101e+04 5.3067e+04 5.3924e+04 5.4697e+04 5.5645e+04];
    PSendtime=[4.8766e+04 5.1236e+04 5.2101e+04 5.3067e+04 5.3924e+04 5.4697e+04 5.5645e+04 5.6579e+04];
end


% %for patient 5
if patno==5
    minvar=40;
    maxvar=100;
    syncFP=4;
    %If BPgreater than 140 or less than 50
    maxval= 150;
    minval = 40;
    maxlimpt=90;
    %PSlevel= [19 17 15 17 19 21 23 19];
    PSlevel= ([22.1 20.1 22.2 24.1 26.1 28.1 24.2])-8;
    PEEP=8;
    PSstarttime=[5.574e+04 5.711+04 5.933e+04 6.036+04 6.115e+04 6.258e+04 6.370e+04 6.470e+04];
    PSendtime=[5.711+04 5.933e+04 6.036+04 6.115e+04 6.258e+04 6.370e+04 6.470e+04 6.542e+04];
end
 


% %for patient 7 
if patno==7
    syncFP1=6;
    syncFP2=12;
    minvar=40;
    maxvar=100;
    %If BPgreater than 140 or less than 50
    maxval= 140;
    minval = 45;
    maxlimpt=90;
    PSlevel= ([20.1 18.1 16.1 14.1 12.1 11.1 9.1 24.1])-6;
    PEEP=6;
    PSstarttime=[3.751e+04 4.181e+04 4.528e+04 4.591e+04 4.678e+04 4.780e+04 4.871e+04 4.939e+04];
    PSendtime=[4.181e+04 4.528e+04 4.591e+04 4.678e+04 4.780e+04 4.871e+04 4.939e+04 5.017e+04];
end

if patno==8
%     PSlevel= [20 18 16 14 12 10 21 10 18 20];
    PSlevel= ([20.1 18.1 16.1 14.1 12.1 10.1 21.1 10.2 18.2 20.2])-9;
    PEEP=9;
    syncFP1=196;
    syncFP2=0;
    PSstarttime=[4.7991e+04 5.0932e+04 5.3629e+04 5.5728e+04 5.6625e+04 5.7403e+04 5.7581e+04 5.7622e+04 5.7959e+04 5.8673e+04];
    PSendtime=[5.0932e+04 5.3629e+04 5.5728e+04 5.6625e+04 5.7403e+04 5.7581e+04 5.7622e+04 5.7959e+04 5.8673e+04 6.0525e+04];
end

% % for patient 9
if patno==9
    minvar= 10;
    maxvar=100;
    %If BPgreater than 140 or less than 50
    maxval= 130;
    minval =50;
    maxlimpt=90;
    %PSlevel= [10 12 10 8 6 4 12];
    PSlevel= ([15.1 17.1 15.2 13.1 11.1 9.1 17.2])-7;
    PEEP=7;
    %PSlevel= ([15.2 17.2 15.1 13.1 11.1 9.1 17.1])-7;
    PSstarttime=[6.106e+04 6.131e+04 6.153e+04 6.533e+04 6.595e+04 6.678e+04 6.786e+04];
    PSendtime=[6.131e+04 6.153e+04 6.533e+04 6.595e+04 6.678e+04 6.786e+04 6.928e+04];
end

% for patient 10
if patno==10
    syncFP1=3;
    syncFP2=6;
    minvar= 40;
    maxvar=100;
    %If BPgreater than 140 or less than 50
    maxval= 160;
    minval =40;
    maxlimpt=90;
    PSlevel= ([17.1 17.2 15.1 13.1 11.1 9.1 8.1 17.3 ])-6;
    PEEP=6;
    PSstarttime=[5.0491e+04 5.2896e+04 5.4748e+04 5.5505e+04 5.6531e+04 5.7236e+04 5.8373e+04 5.9303e+04];
    PSendtime=[5.2896e+04 5.4748e+04 5.5505e+04 5.6531e+04 5.7236e+04 5.8373e+04 5.9303e+04 6.0524e+04];

end

if patno==11
    syncFP=2;
    PSlevel= ([20.1 18.1 20.2 22.1 24.1 26.1 20.3])-5;
    PEEP=5;
    PSstarttime=[4.6579e+04 5.0480e+04 5.1688e+04 5.2747e+04 5.3713e+04 5.4649e+04 5.5383e+04];
    PSendtime=[5.0480e+04 5.1688e+04 5.2747e+04 5.3713e+04 5.4649e+04 5.5383e+04 5.6621e+04];
end

if patno==12
    PSlevel= ([25.1 17.1 15.1 17.2 19.1 21.1 23.1 20.1])-7;
    PEEP=7;
    syncFP=18;
    PSstarttime=[4.6247e+04 4.9788e+04 5.1769e+04 5.3476e+04 5.4426e+04 5.4796e+04 5.5701e+04 5.6454e+04];
    PSendtime=[4.9788e+04 5.1769e+04 5.3476e+04 5.4426e+04 5.4796e+04 5.5701e+04 5.6454e+04 5.7497e+04];
end

if patno==14
    PSlevel= ([18.1 23.1 21.1 20.1 18.2 16.1 14.1 12.1 10.1 20.2])-6;
    PEEP=6;
    syncFP1=11;
    syncFP2=15;
    PSstarttime=[3.5105e+04 4.1053e+04 4.1542e+04 4.2460e+04 4.4827e+04 4.5532e+04 4.6560e+04 4.7606e+04 4.8715e+04 4.9636e+04];
    PSendtime=[4.1053e+04 4.1542e+04 4.2460e+04 4.4827e+04 4.5532e+04 4.6560e+04 4.7606e+04 4.8715e+04 4.9636e+04 5.0212e+04];
end

% ********** Time in seconds starting at 0
PSstarttime=PSstarttime-T0;
PSendtime=PSendtime-T0;