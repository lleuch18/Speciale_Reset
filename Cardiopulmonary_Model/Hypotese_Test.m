% Purpose of this script, is to test the hypothesis, that Crs can be
% estimated at high PS levels, and thus Pmus can be estimated at
% spontaneously breathing patients
%% Initialize experiment

reset= input('Reset variables? [Y]es, [N]o: ','s')

if strcmp(reset,'y') == 1
    clc; clear all; close all;
    global P
    %Initialize Pref
    load('PRef');
    % Initial Settings
    %Lung Properties
    P.resp.R = 2; %Resistance[cmH2O/(S/L)]
    P.resp.Calv = 0.033; %Alveolar Compliance V/P
    P.resp.Crs = 40; %%%%%%PATIENT SPECIFIC%%%%%%%% [mL/cmH2O] -> Remember to convert to [L/cmH2O]
    P.resp.CL = 200; %%%%%%PATIENT SPECIFIC%%%%%%%% [mL/cmH2O] -> Remember to convert to [L/cmH2O]
    P.resp.Cw = 120; %[ml/cmH2o] Calculated as 4% of standard vital capacity
    
    %Vent Settings
    P.resp.PS = 20; %Leveret Tryk
    P.resp.PEEP = 5;
    P.resp.RR = 12; %Respiratory rate in bpm
    P.resp.TCT = 60/P.resp.RR; %Total Cycle Time in seconds
    P.resp.Ti = 1.5; %Inspiratory time seconds   
    P.resp.Te = P.resp.TCT-P.resp.Ti; %Inspiratory time seconds
    P.resp.Trise = P.resp.Ti*0.2; % 20percent of Ti
    P.resp.PSTrigger = -0.0005; % Ppl pressuredrop before delivery of PS [cmH2O]
    
    %Pmus settings
    P.resp.PmusTi = 1.5; %Inspiratory time of Pmus [s]
    P.resp.PmusTe = 2.5; %Expiratory time of Pmus [s]
    P.resp.PmusPause = 0.2; %Pause between insp and exp phase [s]
    P.resp.PmusSet = -12; %Pmus target to reach [cmH2O]
    P.resp.PmusExpLgth = 0.60 %Length between end-inspiration and Pmus reaching 0
    P.resp.PmusCycle = 2; %The flow in [L/S] at which Pmus cycles to passive expiration
    
    %Simulation Parameters
    P.resp.dt = 0.002; %2ms time steps
    P.resp.sim_lgth = 20; %Simulation length in seconds
    P.resp.Tdeflate = 0.4; %Expiratory Time Contant in seconds
    P.resp.cnt = 0; %Count for circumventing errors with indexing in Pmus_Vent
    
    
    %Initial Values
    P.resp.V0 = 3; %Initiel volumen 3L
    P.resp.Palv0 = 5; %Initielt alveolært tryk 5CmH2O (PEEP)
    P.resp.Pao0 = 0; %cmH2O
    P.resp.flow0 = 0; %L/min
    P.resp.Ppl0 = -3; %cmH2O
    P.resp.PaoPrev = 0; %cmH2O Used for calculating dPao
    
    %initial value vector
    P.resp.SV0 = [P.resp.V0,P.resp.flow0,P.resp.Ppl0];%P.resp.Palv0, P.resp.Pao0,
        disp('reset')
end




     

%Choose Patient
patient_nr = input('Choose Patient [2-14] ');
patno_str = num2str(patient_nr);
file_path = strcat('DataP',patno_str,'PS.mat');
%disp(file_path)

%Create var_name and load data
var_name = strcat('patient',patno_str);
temp_data = load(file_path);
data = temp_data.Data;

% Store data columns as individual fields
%Each file contains 8 columns, and each column stores the following variables: 
%time; ecg1 (mV); ecg2 (mV); airway pressure (cmH2O); flow (ml/sec); FeCO2 (%);
%FeO2 (%); and arterial pressure (mmHg). 
P.(var_name).time = data(:,1);P.(var_name).ecg1 = data(:,2);P.(var_name).ecg2 = data(:,3);P.(var_name).pao = data(:,4);
P.(var_name).flow = data(:,5);P.(var_name).FeCO2 = data(:,6);P.(var_name).FeO2 = data(:,7);P.(var_name).ppa = data(:,8);P.(var_name).Data = data;

%% Run plotppv10_r2

run_ppv = input('Run PlotPPV10_r2? [Y], [N]','s')
if strcmp(run_ppv,'y') == 1
%plotppv10_r2
load('Chunk_Process.mat');
end


%% LS algorithm for Raw & Cw estimation

%Initialize variables
part = 1; %%%%Define as part with max PS
num_breaths = 5; %Number of breaths to cycle through
best_j = 10000; % Initial high guess
best_raw = 0; %Initial raw guess
var_pao = std(airpresschunk{part}(:,1));%Variance of pao

%Esimate Raw
raw_guess = [0.5:0.1:20]/10000; %Possible Raw guess range [cmh20/mL/s]

%Make guesse
for ia = 1:length(raw_guess)
    j = 0; %Initial loss
    %Shift through number of breaths
    for b_i = 1:num_breaths  
    %Extract max flow for each breath
    breath_start = NBPdata{1,part}(b_i,5); %5th column is time
    breath_end = NBPdata{1,part}(b_i+1,5);
    
    flow = max(flowchunk{1,1}(ceil(breath_start*100):ceil(breath_end*100))); %Max flow over breath length assumed to be representative of flow reached at Vt
    %Least-Squares Cost Function
    j = j + EOM_cost(NBPdata{1,part}(b_i,7),NBPdata{1,part}(b_i,11),NBPdata{1,part}(b_i,8),flow,raw_guess(ia),var_pao);
    end
    
    if j < best_j
        best_j = j;
        best_raw = raw_guess(ia);
    end
end


%% Prediction & validation framework
%0. Identify relevant timeframes

%Timechunk contains the timeseries identifyer for filtered data. Noisy BP data has been filtered, and thus removed from data.
num_timechunks = length(timechunk); %Num timechunk for the given patients filtered data
num_timeframes = length(NBPdata); %Timeframes contain the breath data of breaths at specific PSlevels, stored together (as opposed to Timechunck, where several timechunks can have the same PSlevel)



for ia = 1:num_timeframes
    P.resp.cnt=0;
% 1. Synchronize breath times from data with model sim_lgth


    switch ia
        case 1; timeframes = [1,2];
        case 2; timeframes = [3,4,5,6,7,8];
        case 3; timeframes = [9,10,11,12];
        case 4; timeframes = [13,14];
        case 5; timeframes = [15,16];
        case 6; timeframes = [17,18];
        case 7; timeframes = [19,20];
    end
    
    

    
    %Check which timechunk breath belongs to, by checking which
        %chunk start time is logged in
    
    %Normalizes breath_length for indexing in NBPdata{ia}        
    b_norm = 0;

    %Shifts through chuncks in timeframes
    for id = 1:length(timeframes)
        chunk = timeframes(id);
        precalc_PPV
        
        %b_length of each chunk added
        if chunk > timeframes(1)
            b_norm = b_norm + length(nd3{chunk-1});
        end

        for b_i = 1:length(nd3{chunk})       
            
            breath = b_i + b_norm;

            P.resp.cnt = P.resp.cnt+1;
            %Threepoint method for detecting insp_length, exp_length and
            %b_length|| b_i+2 <= length(nd3{chunk})
    
            if b_i+1 > length(nd3{chunk})
            start = NBPdata{ia}(breath-2,5)*100;
            midpeak = NBPdata{ia}(breath-1,5)*100;
            endpeak = NBPdata{ia}(breath,5)*100;
    
    
            elseif b_i+2 > length(nd3{chunk})
            start = NBPdata{ia}(breath-1,5)*100;
            midpeak = NBPdata{ia}(breath,5)*100;
            endpeak = NBPdata{ia}(breath+1,5)*100;       
    
            else
            start = NBPdata{ia}(breath,5)*100;
            midpeak = NBPdata{ia}(breath+1,5)*100;
            endpeak = NBPdata{ia}(breath+2,5)*100;
    
            end
    
            
        
            %Normalize indexes with respect to current timechunk
            if chunk > timeframes(1) || ia >= 1
                disp('Activated Special Condition')
                start = start-(timechunk{chunk}(1)*100);
                midpeak = midpeak-(timechunk{chunk}(1)*100);
                endpeak = endpeak-(timechunk{chunk}(1)*100);                               
            end
        
    
           min_start_mid = find(flowchunk{chunk}(start:midpeak)-min(flowchunk{chunk}(start:midpeak))<0.001)+start;
           min_mid_end = find(flowchunk{chunk}(midpeak:endpeak)-min(flowchunk{chunk}(midpeak:endpeak))<0.00001)+midpeak;
            
           %insp_length found by all positive flow values above threshold between minimums
           insp_length = length(find(flowchunk{chunk}(min_start_mid(1):min_mid_end(1))>36)); % [36mL/s] chosen as arbitrary threshold through visual analysis, to filter faux-inspirations and minimal loss.
           %exp_length found by all negative values between two peaks
           exp_length = length(find(flowchunk{chunk}(midpeak:endpeak)<-8));
    
           b_length = insp_length+exp_length;
        P\ 
            % 2. Extract PPV data at filtered breath timeframes 
            d3 = nd3{chunk}(b_i); %d3=maxinsp-minexp
            d4 = nd4{chunk}(b_i); %d4=mininsp-maxexp
    
            % 3. Extract Pmus parameter at breath
            P.resp.PmusSet = -1*pmus{chunk}(b_i);
            % 4. Extract Ceff
            P.resp.Crs = NBPdata{ia}(breath,8);
            % 5. Input Raw 
            P.resp.R = best_raw*10000;        
            
            % 6. Run cardiopulmonary model at breath
            % 6a Run respiratory Model at breath
            %Vent Settings
            P.resp.PS = NBPdata{ia}(breath,7);
            P.resp.PEEP = NBPdata{ia}(breath,4)-NBPdata{ia}(breath,7);
            P.resp.Ti = insp_length/100; %Inspiration time as insp_length
            P.resp.Te = exp_length/100; % -||- 
            P.resp.TCT = b_length/100; %Total Cycle Time in seconds
            P.resp.Trise = P.resp.Ti*0.2; % 20percent of Ti   
            P.resp.PSTrigger = -0.08; % Ppl pressuredrop before delivery of PS [cmH2O]
            
            %Pmus settings
            P.resp.PmusTi = insp_length/100; %Inspiratory time of Pmus [s]
            P.resp.PmusTe = exp_length/100; %Expiratory time of Pmus [s]       
            
            

            %Save settings for diagnostics
            P.model{b_i,chunk}.PS =  P.resp.PS; P.model{b_i,chunk}.PEEP =  P.resp.PEEP;P.model{b_i,chunk}.Ti =  P.resp.Ti;P.model{b_i,chunk}.Te =  P.resp.Te;
            P.model{b_i,chunk}.TCT =  P.resp.TCT; P.model{b_i,chunk}.Trise =  P.resp.Trise; P.model{b_i,chunk}.PmusTi =  P.resp.PmusTi;P.model{b_i,chunk}.PmusTe =  P.resp.PmusTe;
            
           
    
            %Run Model
            Respiratory_Modelfn_PS(P.resp.Ppl0,0,P.resp.TCT,chunk,b_i)     
            
            %Reset P.resp.fields to ready for new breath
            if isfield(P.resp, 'Pmus_Exp_PSTrigger') == 1     
                P.resp=rmfield(P.resp,'Pmus_Exp_PSTrigger');
            end  
    
            if isfield(P.resp, 'Pmus_Exp_NoTrigger') == 1   
                P.resp=rmfield(P.resp,'Pmus_Exp_NoTrigger');
            end
            
        end
    %% 6b Run Intrathoracic Model at chunk
    %{
    if ia == 1
        if exist('chunk_end','var') == 0
            chunk_end = 0
        end

        start_index = 0
        for b = 1:length(nd3{chunk})
      
            %Ensure that each individual breath gets correctly logged within
            %PPV chunk
            if b > 1
                start_index = start_index + length(P.model{b-1,chunk}.data);        
            end 
    
            if b == 1
                %Sets start index to continue at the last chunk
                start_index = 0 + chunk_end;
            end
    
            intrathoracic_model(P.model{b,chunk}.data(:,5),0.1,chunk,start_index)
        end
    chunk_end = start_index;
    end
 %}
    end
    chunk_end = 0;
    
end




%% Plot results simulated with extracted parameters
figure() ; 

%flow = 1; V = 2; Pvent = 3; Pmus = 4; Ppl = 5; Pao = 6;

chunk = 1;
breath = 9;
plotId = 1;
    subplot(3, 3, plotId)
    plot(P.model{breath,chunk}.data(:,6))
    title('Pao')
    subplot(3, 3, plotId+1)    
    plot(P.model{breath,chunk}.data(:,5))
    title('Ppl')
    subplot(3, 3, plotId+2)
    plot(P.model{breath,chunk}.data(:,1))
    title('flow')
    subplot(3, 3, plotId+3)
    plot(P.model{breath,chunk}.data(:,3))
    title('Pvent')
    subplot(3, 3, plotId+4)
    plot(P.model{breath,chunk}.data(:,4))
    title('Pmus')

%% 
%% 6b Run Intrathoracic Model at chunk
chunk_end = 0;
start_index = 0;
for chunk = 1:2
    for b = 1:length(nd3{chunk})
        
        if b == 1
            %Sets start index to continue at the last chunk
            start_index = 0 + chunk_end;
        end
        %Ensure that each individual breath gets correctly logged within
        %PPV chunk
        if b > 1
            start_index = start_index + length(P.model{breath-1,chunk}.data);        
        end        

        intrathoracic_model(P.model{b,chunk}.data(:,5),0.1,chunk,start_index,b)
    end
    chunk_end = start_index;
end
%%

%{
for i = 1:length(P.PPV{1}.pu_art_post)
    if P.PPV{1}.pu_art_post(i) < 20
        P.PPV{1}.pu_art_post(i) = 110
    end
end
%}
close all;
%figure(9)
%plot(P.PPV{1}.pu_art_pre)
%title('Pu_art_pre')

figure(10)
plot(P.PPV{1}.pu_art_post(1:47000))
title('Pu_art_post')


%6. Compare Simulated vs. measured PPV at timeframes


%7. Compute loss



%8. Conclude on hypothesis

%% 
b = 0;
for i = 1:15
    b = b + length(P.model{i,2}.data)
end
a = 29778;
b = 28915;

%%
test = find(flowchunk{1}(round(14.8,3)*100:round(18.3,3)*100)>36);
test2 = flowchunk{1}(test);
plot(test2)
%%























%% Functions
function j = EOM_cost(pao,vt,crs,flow,raw_guess,std_pao)
j = ((pao-((vt/crs)+(raw_guess*flow)))^2)/std_pao;
disp(num2str(j))
disp(['vt/crs ',num2str(vt/crs)])
disp(['raw_guess*flow ',num2str(raw_guess*flow), 'raw_guesse: ',num2str(raw_guess), 'flow: ',num2str(flow)])

disp(['pao ',num2str(pao)])
disp(['(vt/crs)+(raw_guess*flow): ',num2str((vt/crs)+(raw_guess*flow))])
end