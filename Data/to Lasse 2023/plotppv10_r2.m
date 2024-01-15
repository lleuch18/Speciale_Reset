%Here are the files from the PS protocol including the arterial pressure. 
%Each file contains 8 columns, and each column stores the following variables: 
%time; ecg1 (mV); ecg2 (mV); airway pressure (cmH2O); flow (ml/sec); FeCO2 (%);
%FeO2 (%); and arterial pressure (mmHg). 

close all
clear all
clc

%filt=0;
filt=1;

% patients rev and checked 2 3 4 5 7 8 9* 10** 12 14
% pending 11**

% *  irregular heart beating pattern at all PS levles
% ** irregular heart beating pattern at high PS

% **********
patno=2; 
plotonoff=2;
% plotonoff
    % 0 plot-off;
    % 1 plot-on; all PA points identified: HR/FR=all
    % 2 plot-on;     PA points identified: HR/FR>3.4; and 20>(sys-dia)<80
  
% * * * * * * * * * * code
load( ['DataP' num2str(patno) 'PS'])


T0=Data(1,1);
NDATA=size(Data,1);
timepre= (Data(:,1)-T0); % time in seconds starting in 0
flowpre= -Data(:,5);
airpresspre= zeros(NDATA,1);
artpresspre=Data(:,8);


% ********** Settings for individual patients

% % % no filter
if patno==3 || patno==8 || patno==11 || patno==12 || patno==14
    minvar=10;
    maxvar=180;
    % %If BPgreater than 140 or less than 50
    maxval= 250;
    minval = 10;
end


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
% ********** PAW synchronization with flow signal
if patno==3 || patno==5 || patno==11 || patno==12
    airpresspre(1:NDATA-syncFP,1)= Data(syncFP+1:NDATA,4);
elseif patno==2
    airpresspre(1:51841-syncFP1,1)=Data(syncFP1+1:51841,4);
    airpresspre(51842:NDATA-syncFP2,1)=Data(syncFP2+51842:NDATA,4);
elseif patno==4
    airpresspre(1:581321-syncFP1,1)=Data(syncFP1+1:581321,4);
    airpresspre(581321:NDATA-syncFP2,1)=Data(syncFP2+581321:NDATA,4);
elseif patno==7
    airpresspre(1:448020,1)= Data(1:448020,4);
    airpresspre(448021:1073581-syncFP1,1)=Data(syncFP1+448021:1073581,4);
    airpresspre(1073641:1188541-syncFP2,1)=Data(syncFP2+1073641:1188541,4);
    airpresspre(1201441:NDATA,1)= Data(1201441:NDATA,4);
elseif patno==8
    airpresspre(1:86461-syncFP1,1)=Data(syncFP1+1:86461,4);
    airpresspre(86461:NDATA-syncFP2,1)=Data(syncFP2+86461:NDATA,4);
elseif patno==10
    airpresspre(1:732660-syncFP1,1)=Data(syncFP1+1:732660,4);
    airpresspre(732661:NDATA-syncFP2,1)=Data(syncFP2+732661:NDATA,4);
elseif patno==14
    airpresspre(1:1150320-syncFP1,1)=Data(syncFP1+1:1150320,4);
    airpresspre(1150321:NDATA-syncFP2,1)=Data(syncFP2+1150321:NDATA,4);
else
    airpresspre= Data(:,4);
end
%
% % Pre-filter plots
% 
% %flow
% figure
% plot(time,flow)
% 
% %airway pressure
% figure
% plot(time,airpress)
% 
% %arterial pressure
% figure
% plot(time,artpress)

% both pressure plots
figure
% airway pressure scaled with a factor of 10
plot(timepre,airpresspre*10)
hold on
% arterial pressure
plot(timepre,artpresspre,'r')
% airway flow
plot(timepre,flowpre/10,'g')

title('raw data scaled, green gas flow, red blood pressure, blue airway pressure')



% ********** PArt filtering
if filt == 1
    [starttimefiltref, endtimefiltref] =filterbp(timepre,flowpre,airpresspre,...
        artpresspre,minvar,maxvar,maxval,minval);
else
%     time= timepre;
%     flow= flowpre;
%     airpress= airpresspre;
%     artpress=artpresspre;
end

% for i=1:(length(time)-1)
%     timediff(i)=time(i+1)-time(i);
% end

% % both pressure plots
% figure
% % airway pressure scaled with a factor of 10
% plot(time,airpress*10,'b')
% hold on
% % arterial pressure
% plot(time,artpress,'r*')
% % airway flow
% plot(time,flow/10,'g')

figure
% arterial pressure

plot(timepre,artpresspre,'r')
hold on

%
%t1=1; t2=0;
for i= 1: length(starttimefiltref)
    timechunk{i}= timepre(starttimefiltref(i):endtimefiltref(i));
    flowchunk{i}= flowpre(starttimefiltref(i):endtimefiltref(i));
    airpresschunk{i}= airpresspre(starttimefiltref(i):endtimefiltref(i));
    artpresschunk{i}= artpresspre(starttimefiltref(i):endtimefiltref(i));
    t1=1;
    while t1<=numel(PSlevel)
       if PSstarttime(t1)<=timechunk{i}(1,1)
           PSlevellabel(i,1)=PSlevel(t1);
       end
        t1=t1+1;
    end
    t1=1;
    while t1<=numel(PSlevel)
       if timechunk{i}(end,1)<=PSendtime(t1)
           PSlevellabel(i,2)=PSlevel(t1);
           break
       end
        t1=t1+1;
    end

    % plot(timechunk{i},artpresschunk{i})
   
   
end

%% begining of process chunk
% plot on-off                       
for i=1:length(starttimefiltref)
    [partsys{i}, startinsp{i}, startexp{i}, p3array{i},...
        partsysmaxinsp{i}, partsysmaxexp{i}, partsysmininsp{i}, partsysminexp{i}, ...
        pPART{i}, vPART{i}, VT{i},pPART2{i}, pPART3{i}, vPART2{i}, VT2{i}, ...
        minPAinsp{i}, PPVd3{i}, PPVd4{i}, SDE2{i}]=...
        processchunkPPV(timechunk{i},flowchunk{i},...
        airpresschunk{i},artpresschunk{i},patno,PEEP,plotonoff, PSlevellabel(i,:),i);
end


%% Plots considering one heart beat or more per inspiration
%% storing d3=par_max insp- par_min exp in a matrix for boxplotting
ia=1;
ib=1;
nPS=0;
temp=0;
NBPdata{1}=zeros(1,13);
for i=1:length(starttimefiltref)
    nd3{i}=vPART2{i}(:,2)-vPART2{i}(:,3);   % max insp - min exp
    
    for id=1:size(vPART2{i},1)
        if minPAinsp{i}(id,2)==0
            nd4{i}(id,1)=vPART2{i}(id,2)-vPART2{i}(id,6);   % min insp - max exp
                                                            % max exp - min insp
            tempp(id,1)=vPART2{i}(id,2);
        else
            nd4{i}(id,1)=minPAinsp{i}(id,3)-vPART2{i}(id,6);
            tempp(id,1)=minPAinsp{i}(id,3);
        end
    end
    nr=size(vPART2{i},1);
    if  vPART2{i}(1,5)~=0
        if vPART2{i}(1,5)> PSendtime(ib)
            
            ib=ib+1;
            ia=1; 
        end
        NBPdata{ib}(ia:ia+nr-1,1:6)=vPART2{i}(:,1:6);% breath_no,partsys max insp,partsys min exp,PAW, time, partsys max exp,
        NBPdata{ib}(ia:ia+nr-1,7)=PSlevel(ib);      % PS level
        NBPdata{ib}(ia:ia+nr-1,8)=VT2{i}(:,2);      % ceff
        NBPdata{ib}(ia:ia+nr-1,9)=tempp;            % part sys min insp
        NBPdata{ib}(ia:ia+nr-1,10)=pPART2{i}(:,5);  % measured pressure PAW-PEEP.
        NBPdata{ib}(ia:ia+nr-1,11)=VT2{i}(:,1);     % tidal volume
        tempp=0;
        ia=ia+nr;
        if temp~=PSlevel(ib)
            temp=PSlevel(ib);
            
            nPS=nPS+1;
            PSlevel2(ib)=PSlevel(nPS);
        end
    end
end
for ia=1:nPS
    nBPcolor(ia)='k';
end
for ia=nPS+1:2*nPS
    nBPcolor(ia)='b';
end
%
for ia= 1:2:(2*nPS)-1
    nBPcolor2(ia)='b';
    nBPcolor2(ia+1)='k';
end
%
temp=0;
for ia=1:size(NBPdata,2)
    if size(NBPdata{ia}(:,:),1)>temp
        temp=size(NBPdata{ia}(:,:),1);
    end
end
%
nBPdata2=NaN(temp,size(NBPdata,2));
nBPdata3=NaN(temp,size(NBPdata,2)); 
ic=1;
for ia=1:size(NBPdata,2)
    if NBPdata{ia}(1,1)~=0
        nBPdata2(1:size(NBPdata{ia}(:,:),1),ia)=NBPdata{ia}(:,2)-NBPdata{ia}(:,3); %d3=maxinsp-minexp
        nBPdata3(1:size(NBPdata{ia}(:,:),1),ia)=NBPdata{ia}(:,9)-NBPdata{ia}(:,6); %d4=mininsp-maxexp
        nBDdata4(ic:ic-1+size(NBPdata{ia}(:,:),1),2)=nBPdata2(1:size(NBPdata{ia}(:,:),1),ia);
        nBDdata4(ic:ic-1+size(NBPdata{ia}(:,:),1),1)=NBPdata{ia}(:,7);
        nBDdata5(ic:ic-1+size(NBPdata{ia}(:,:),1),2)=nBPdata3(1:size(NBPdata{ia}(:,:),1),ia);
        nBDdata5(ic:ic-1+size(NBPdata{ia}(:,:),1),1)=NBPdata{ia}(:,7);
        nBDdata7(ic:ic-1+size(NBPdata{ia}(:,:),1),2)=NBPdata{ia}(:,8);     % ceff
        nBDdata7(ic:ic-1+size(NBPdata{ia}(:,:),1),1)=NBPdata{ia}(:,7);
        ic=ic+size(NBPdata{ia}(:,:),1);
    end
end
%
nBPdata4=sortrows(nBDdata4,1); % d3
nBPdata5=sortrows(nBDdata5,1); % d4
nBPdata7=sortrows(nBDdata7,1);
nBPdata5(:,2)=-1*(nBPdata5(:,2)); %-d4
%
ic=1;
for ia=1:size(nBPdata4,1)
    if nBPdata4(ia,1)<10
        nBPlab1(ia,1:7)=['D3 0' num2str(nBPdata4(ia,1))];
        nBPlab2(ia,1:7)=['D4 0' num2str(nBPdata5(ia,1))];
        nBPlab4(ia,1:7)=['PS 0' num2str(nBPdata7(ia,1))];
    else
        nBPlab1(ia,1:7)=['D3 ' num2str(nBPdata4(ia,1))];
        nBPlab2(ia,1:7)=['D4 ' num2str(nBPdata5(ia,1))];
        nBPlab4(ia,1:7)=['PS ' num2str(nBPdata7(ia,1))];
    end
    if ia>2
        if nBPdata4(ia-1,1)<nBPdata4(ia,1)
            nlabindex(ic,1)=ia-1;
            ic=ic+1;
        end
    end
end
nlabindex(ic,1)=size(nBPdata4,1);
nBPdata6=sortrows([nBPdata4 zeros(size(nBPdata4,1),1);
    nBPdata5 ones(size(nBPdata5,1),1)],1);

% 
ic=1;
for ia=1:size(nBPdata6,1)
    if nBPdata6(ia,1)<10
        if nBPdata6(ia,3)==0
            nBPlab3(ia,1:7)=['D3 0' num2str(nBPdata6(ia,1))];
        else
            nBPlab3(ia,1:7)=['D4 0' num2str(nBPdata6(ia,1))];
        end
    else
        if nBPdata6(ia,3)==0
            nBPlab3(ia,1:7)=['D3 ' num2str(nBPdata6(ia,1))];
        else
            nBPlab3(ia,1:7)=['D4 ' num2str(nBPdata6(ia,1))];
        end
    end
end

% %% plots for:
% % d3= (partmaxsysinsp-partminsysexp)
% % d3 vs PS
% figure
% hold on
% for i=1:length(starttimefiltref)
%     if vPART2{i}(1,4)~=0
% %         plot(vPART2{i}(:,4),nd3{i},'k+','markersize',12,'linewidth',1)
%         plot(pPART2{i}(:,5),nd3{i},'bx','markersize',12,'linewidth',1)
%     end
% end
% xlabel('PS (cm H2O)')
% ylabel('d3 (mm Hg)')
% title(['Patient ' num2str(patno) '  d3 vs time'])
% % d4 vs PS
% figure
% hold on
% for i=1:length(starttimefiltref)
%     if vPART2{i}(1,4)~=0
% %         plot(vPART2{i}(:,4),nd3{i},'k+','markersize',12,'linewidth',1)
%         plot(pPART2{i}(:,5),nd4{i},'kx','markersize',12,'linewidth',1)
%     end
% end
% xlabel('PS (cm H2O)')
% ylabel('d4 (mm Hg)')
% title(['Patient ' num2str(patno) '  d3 vs time'])
% 
% %
% % d3 vs time
% figure
% hold on
% for i=1:length(starttimefiltref)
%     if vPART2{i}(1,4)~=0
%         plot(vPART2{i}(:,5),nd3{i},'bx','markersize',12,'linewidth',1)
%     end
% end
% xlabel('time')
% ylabel('d3 (mm Hg)')
% title(['Patient ' num2str(patno) '  d3 vs time'])
% %
% % Part_sys_insp_max vs time
% figure
% hold on
% for i=1:length(starttimefiltref)
%     if vPART2{i}(1,4)~=0
%         plot(vPART2{i}(:,5),vPART2{i}(:,2),'bx','markersize',12,'linewidth',1)
%     end
% end
% xlabel('time')
% ylabel('Partsys_{max}insp (mm Hg)')
% title(['Patient ' num2str(patno) '  Part_sys vs time'])
% %
%% PS vs time
figure
hold on
for i=1:length(starttimefiltref)
    if vPART2{i}(1,4)~=0
%         plot(vPART2{i}(:,5),vPART2{i}(:,4),'kx','markersize',12,'linewidth',1)
        plot(vPART2{i}(:,5),pPART2{i}(:,5),'r+','markersize',12,'linewidth',1)
    end
end
xlabel('time')
ylabel('PS (cm H2O)')
title(['Patient ' num2str(patno) '  PS vs time'])
%
%% d3 and -d4 boxplots - one side from the "u" shape
% d3 Partsys_maxinsp - Partsys_minexp (blue) (magenta)
% d4 Partsys_mininsp - Partsys_maxexp (black) (green)
figure
% d4, d3
boxplot([nBPdata5(:,2);nBPdata4(:,2)],[nBPlab2;nBPlab1],'colors',nBPcolor)
xlabel('PS level (cm H2O)')
ylabel('d3, -d4 (mm Hg)')
title(['Patient ' num2str(patno) '  d3 and -d4 '])
% crossing - is the same as the previous plot
figure
% d3, d4
boxplot(nBPdata6(:,2),nBPlab3,'colors',nBPcolor2)
xlabel('PS level (cm H2O)')
ylabel('d3, -d4 (mm Hg)')
title(['Patient ' num2str(patno) '  d3 and -d4']) %Pmaxsysinsp-Pminsysexp'])
%
%% Ceff
figure
boxplot(nBPdata7(:,2),nBPlab4)
ylim([0 400])
xlabel('PS level (cm H2O)')
ylabel('Ceff')
title(['Ceff Patient ' num2str(patno)])

%% min ceff, VT above min ceff*PS is generated by Pmus. Method for calculating surrogate Pmus
[~,pos1]=max(nBPdata7(:,1));
CRS=median(nBPdata7(pos1:end,2));

%% VTmeasured - PS * CRS
figure
hold on
for ib=1:length(starttimefiltref)
    if vPART2{ib}(1,4)~=0
        plot(vPART2{ib}(:,5),VT2{ib}(:,1)-(pPART2{ib}(:,5)*CRS),'k.','markersize',14,'linewidth',2)
    end
end
xlabel('time')
ylabel('VT_{meas}-PS*CRS (ml)')
title(['Patient ' num2str(patno) '  muscle diven VT'])
%
%% Pmus surrogate
figure
hold on
for i=1:length(starttimefiltref)
    if vPART2{i}(1,4)~=0
        plot(vPART2{i}(:,5),(VT2{i}(:,1)-(pPART2{i}(:,5)*CRS))/CRS,'b.','markersize',14,'linewidth',2)
    end
end
xlabel('time')
ylabel('Pmus_{surrogate} (cm H2O)')
title(['Patient ' num2str(patno) '  surrogate Pmus'])
%
%% Pmus calculation
for i=1:length(starttimefiltref)
    if vPART2{i}(1,4)~=0
        pmus{i}(:,1)=(VT2{i}(:,1)-(pPART2{i}(:,5)*CRS))/CRS;
    end
end
%
%% Pmus calculation
for i=1:size(NBPdata,2)
    NBPdata{i}(:,12)=NBPdata{i}(:,2)-NBPdata{i}(:,3);       % d3 maxinsp - minexp
    NBPdata{i}(:,13)=NBPdata{i}(:,6)-NBPdata{i}(:,9);       % -d4 -(mininsp -maxexp)
    NBPdata{i}(:,14)=(NBPdata{i}(:,11)-(NBPdata{i}(:,10)*CRS))/CRS;     % vt_musc_driven
end
%
%%
% d3 vs Pmus_surrogate
figure
hold on
for i=1:length(starttimefiltref)
    if vPART2{i}(1,4)~=0
        plot(nd3{i},pmus{i},'b.','markersize',15,'linewidth',2)
%        plot(nBDdata4{i}(:,2),pmus{i},'b.','markersize',15,'linewidth',2)
    end
end
axis equal
xlabel('d3 (mm Hg)')
ylabel('Pmus_{surrogate} (cm H2O)')
title(['Patient ' num2str(patno) '  Pmus_{surrogate} vs d3'])
% -d4 vs Pmus_surrogate
figure
hold on
for i=1:length(starttimefiltref)
    if vPART2{i}(1,4)~=0
        plot(-nd4{i},pmus{i},'k.','markersize',12,'linewidth',1)
    end
end
xlabel('-d4 (mm Hg)')
ylabel('Pmus_{surrogate} (cm H2O)')
title(['Patient ' num2str(patno) '  Pmus_{surrogate} vs -d4'])

%%
% d3 and -d4 vs Pmus_surrogate
figure
hold on
for i=1:size(NBPdata,2)
        plot(NBPdata{i}(:,12),NBPdata{i}(:,14),'b.','markersize',15,'linewidth',2)
end

for i=1:size(NBPdata,2)
        plot(NBPdata{i}(:,13),NBPdata{i}(:,14),'k.','markersize',12,'linewidth',2)
end
axis equal
xlabel('d3, -d4 (mm Hg)')
ylabel('Pmus_{surrogate} (cm H2O)')
title(['Patient ' num2str(patno) ' Pmus_{surrogate} vs d3 and -d4 '])
%%  d3 and -d4 plots for HR/FR>=3.4
if plotonoff==2
    figure
    hold on
    for ib=1:length(starttimefiltref)
        if size(PPVd3{ib},1)>1
            plot(timechunk{ib}(PPVd3{ib}(:,1),1), PPVd3{ib}(:,2),'bs') % maxinsp-minexp  
            plot(timechunk{ib}(PPVd4{ib}(:,1),1),-PPVd4{ib}(:,2),'ko')  %-(mininsp - maxexp)
        end
    end
    xlabel('time (s)')
    ylabel('d3, -d4 (mm Hg)')
    title(['Patient ' num2str(patno) '  d3 and -d4 for HR/FR>=3.4'])
    %
    figure
    hold on
    for ib=1:length(starttimefiltref)
        if size(PPVd3{ib},1)>1
            plot(PPVd3{ib}(:,3), PPVd3{ib}(:,2),'bs') %  maxinsp-minexp
            plot(PPVd4{ib}(:,3),-PPVd4{ib}(:,2),'ko')  % -(mininsp - maxexp)
        end
    end
    
    xlabel('PS level (cm H2O)')
    ylabel('d3, -d4 (mm Hg)')
    title(['Patient ' num2str(patno) ' d3 and -d4 for HR/FR>=3.4'])
    % pmus for HR/FR>=3.4
    figure
    hold on
    for ib=1:length(starttimefiltref)
        if size(PPVd3{ib},1)>1
            plot( PPVd3{ib}(:,2),(PPVd3{ib}(:,4)-(CRS*PPVd3{ib}(:,3)))/CRS,'bs')
            plot(-PPVd4{ib}(:,2),(PPVd4{ib}(:,4)-(CRS*PPVd4{ib}(:,3)))/CRS,'ko')
        end
    end
    xlabel('d3, -d4 (mm Hg)')
    ylabel('Pmus_{surrogate} (cm H2O)')
    title(['Patient ' num2str(patno) ' Pmus_{surrogate} vs d3 and -d4 for HR/FR>=3.4'])
    
end
%%

%% Slope plots
figure
hold on
for i=1:length(starttimefiltref)
    if size(SDE2{i},1)>1
        plot(SDE2{i}(:,2),SDE2{i}(:,3), 'b.', 'markersize',14);
    end

end
xlabel('Time')
ylabel('Slope (mm Hg / sec)')
title(['Patient ' num2str(patno) ' Time Vs Expiratory Arterial pressure slope']);
%%
figure
hold on
for i=1:length(starttimefiltref)
    if size(SDE2{i},1)>1
        plot(PPVd3{i}(:,3),SDE2{i}(:,3), 'b.', 'markersize',14);
    end

end
xlabel('PS (cm H_2O)')
ylabel('Slope (mm Hg / sec)')
title(['Patient ' num2str(patno) ' PS-level Vs Expiratory Arterial pressure slope']);
%%
if plotonoff==2
    figure
    hold on 
    for ib=1:length(starttimefiltref)
        if size(PPVd3{ib},1)>1
            for ic=1:size(SDE2{ib},1)
                if SDE2{ib}(ic,3)<0
                    plot(PPVd3{ib}(ic,3), PPVd3{ib}(ic,2),'bs') %  maxinsp-minexp
                else
                    plot(PPVd4{ib}(ic,3), PPVd4{ib}(ic,2),'ko')  % (mininsp - maxexp)
                end
            end
        end
    end
    
    xlabel('PS level (cm H2O)')
    ylabel('d3, d4 (mm Hg)')
    title(['Patient ' num2str(patno) ' HR/FR>=3.4; if slope<0 d3(bs) else d4 (ko)'])
end

%%
if plotonoff==2
    figure
    hold on
    for ib=1:length(starttimefiltref)
        if size(PPVd3{ib},1)>1
            for ic=1:size(SDE2{ib},1)
                if SDE2{ib}(ic,3)<0
                    plot( PPVd3{ib}(ic,2),(PPVd3{ib}(ic,4)-(CRS*PPVd3{ib}(ic,3)))/CRS,'bs')
                    
                else
                    plot( PPVd4{ib}(ic,2),(PPVd4{ib}(ic,4)-(CRS*PPVd4{ib}(ic,3)))/CRS,'ko')
                end
            end
        end
    end
    
    xlabel('d3, d4 (mm Hg)')
    ylabel('Pmus_{surrogate} (cm H2O)')
    title(['Patient ' num2str(patno) ' HR/FR>=3.4; Pmus_{surrogate} if slope<0 d3(bs) else d4(ko)'])
end

%% **** uncomment for plotting 3D plots
% %% 3D plots
% %% PS, d3 d4, Pmus
% if plotonoff==2
%     figure
%     hold on
%     for ib=1:length(starttimefiltref)
%         if size(PPVd3{ib},1)>1
%             for ic=1:size(SDE2{ib},1)
%                 if SDE2{ib}(ic,3)<0
%                     plot3( PPVd3{ib}(ic,3),PPVd3{ib}(ic,2),(PPVd3{ib}(ic,4)-(CRS*PPVd3{ib}(ic,3)))/CRS,'bs')
%                     
%                 else
%                     plot3( PPVd4{ib}(ic,3),PPVd4{ib}(ic,2),(PPVd4{ib}(ic,4)-(CRS*PPVd4{ib}(ic,3)))/CRS,'ko')
%                 end
%             end
%         end
%     end
%     grid on
%     xlabel('PS (cm H_2O)')
%     ylabel('d3, d4 (mm Hg)')
%     zlabel('Pmus_{surrogate} (cm H2O)')
%     title(['Patient ' num2str(patno) ' HR/FR>=3.4; Pmus_{surrogate} if slope<0 d3(bs) else d4(ko)'])
% end
% %% Ceff, d3 d4, Pmus
% if plotonoff==2
%     figure
%     hold on
%     for ib=1:length(starttimefiltref)
%         if size(PPVd3{ib},1)>1
%             for ic=1:size(SDE2{ib},1)
%                 if SDE2{ib}(ic,3)<0
%                     plot3( PPVd3{ib}(ic,4)/PPVd3{ib}(ic,3),PPVd3{ib}(ic,2),(PPVd3{ib}(ic,4)-(CRS*PPVd3{ib}(ic,3)))/CRS,'bs')
%                     
%                 else
%                     plot3( PPVd4{ib}(ic,4)/PPVd4{ib}(ic,3),PPVd4{ib}(ic,2),(PPVd4{ib}(ic,4)-(CRS*PPVd4{ib}(ic,3)))/CRS,'ko')
%                 end
%             end
%         end
%     end
%     grid on
%     xlabel('ceff (ml/cm H_2O)')
%     ylabel('d3, d4 (mm Hg)')
%     zlabel('Pmus_{surrogate} (cm H2O)')
%     title(['Patient ' num2str(patno) ' HR/FR>=3.4; Pmus_{surrogate} if slope<0 d3(bs) else d4(ko)'])
% end
% %% 1/Ceff, d3 d4, Pmus
% if plotonoff==2
%     figure
%     hold on
%     for ib=1:length(starttimefiltref)
%         if size(PPVd3{ib},1)>1
%             for ic=1:size(SDE2{ib},1)
%                 if SDE2{ib}(ic,3)<0
%                     plot3( PPVd3{ib}(ic,3)/PPVd3{ib}(ic,4),PPVd3{ib}(ic,2),(PPVd3{ib}(ic,4)-(CRS*PPVd3{ib}(ic,3)))/CRS,'bs')
%                     
%                 else
%                     plot3( PPVd4{ib}(ic,3)/PPVd4{ib}(ic,4),PPVd4{ib}(ic,2),(PPVd4{ib}(ic,4)-(CRS*PPVd4{ib}(ic,3)))/CRS,'ko')
%                 end
%             end
%         end
%     end
%     grid on
%     xlabel('1/ceff (cm H_2O/ml)')
%     ylabel('d3, d4 (mm Hg)')
%     zlabel('Pmus_{surrogate} (cm H2O)')
%     title(['Patient ' num2str(patno) ' HR/FR>=3.4; Pmus_{surrogate} if slope<0 d3(bs) else d4(ko)'])
% end