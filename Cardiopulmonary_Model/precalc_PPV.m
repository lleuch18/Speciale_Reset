P.resp.sim_lgth=0; %Sim_lgth of cardiovascular model computed for each timeframe

    for ic = 1:length(timeframes)            
        P.resp.sim_lgth = P.resp.sim_lgth+(length(timechunk{ic})*0.01); %Patient data sampled at 100Hz
    end

    % 6c Run full cardiovascularmodel for timeframe length
    %circ_run = input('Run Circadapt? [Y],[N]','s')

    if strcmp(circ_run,'y') == 1
        if length(P.Node.p) < 10000 %Pref has length 853, as such this will run only once per timeframe (for speeding testing) 
            %CircAdaptFinal;
            load('Chunk_CircAdapt_Workspace.mat')
        end
    end
    

    % PuArt filter and plot
    close all;
    pSc= Rnd(0.1*P.General.p0);
    figure(6);
    p6=(GetFt('Node','p',{'PuArt'})/pSc)*round(7.5,3); %Convert to kPa and then CmH2O
    p6 = p6+(P.General.p0/pSc)*round(7.5,3);
    %p6=GetFt('Node','p',{'PuArt'});
    
    beat_length = P.General.tCycle;
    
    %1. find min value; 2. log values from min value to minvalue+beat length;
    i_start = find(p6==min(p6))-(beat_length/P.General.Dt);%Shift 1 heart beat from min to not exceed array length
    i_end = i_start+(beat_length/P.General.Dt);
    proto = p6(i_start:i_end);
    
    if isfield(P,'PPV{chunk}') == 0 %Temporary solution for adding PPV field - change when cardiovascular model run simultaneously
        P.PPV{chunk}.pu_art_pre = zeros(length(P.Node.p),1);
    end
    
    cnt=0;
    for id = 1:length(P.PPV{chunk}.pu_art_pre)
        
        if mod(id,1000) == 0
            disp(['ran iteration nr at PuArt: ',num2str(id)])
        end
    
    
        P.PPV{chunk}.pu_art_pre(id) = proto(id-cnt*(length(proto)));
    
        if mod(id,round(length(proto))) == 0 && id > 1
            cnt = cnt+1;
            disp(['cnt is:',num2str(cnt)])
            disp(['at ia+1: ',num2str(id+1)])
            disp(['cnt*length ',num2str(cnt*length(proto))])
        end   

        if id == length(p6)
            break
        end
    end