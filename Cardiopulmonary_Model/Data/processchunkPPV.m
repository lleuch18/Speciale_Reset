%% modified processchunk moving average timewin=3
function [partsys, startinsp, startexp, p3array, ...
        partsysmaxinsp, partsysmaxexp, partsysmininsp, partsysminexp, ...
        pPART, vPART, VT, pPART2, pPART3, vPART2, VT2, minPAinsp, PPVd3,...
        PPVd4, SDE2] = processchunkPPV(time, flow, ...
        airpress, artpress, patno, PEEP, plotonoff, pslab, chunki)
%% 1 Script for determining systolic pressures
% ************** 
% i=1;
% time=timechunk{i};
% flow=flowchunk{i};
% airpress=airpresschunk{i};
% artpress=artpresschunk{i};
% patno=14;
% PEEP=7;
% plotonoff=1;
% pslab=[0,0];
% ************** 
% Identification of systolic and diastolic pressures for each heart beat
%       determining sens parameter.
minDP=20;
maxDP=80;
if patno==5
    sens=15;
else
    sens=10;
end
partsys=part_sys5(artpress, sens); % systolic and diastolic pressure data

% Setting label for plot according to pressure support level
if pslab(1,1)==pslab(1,2) || pslab(1,2)==0
    tlab=pslab(1,1);
else
    tlab=[pslab(1,1) pslab(1,2)];
end
% 2 script for determining inspiratory and expiratory phase and pointthree
[startinsp,startexp]=start_ie2(flow);
% 
if size(startinsp,1)~=1
    % 3 determining pointthree
    % locating the starting inspiratory pressure
    pos=startinsp;
    for ia=1:numel(pos)
        startinspairpress=airpress(pos(ia,1),1);
        ib=1;
        flg=0;
        pressuretimeproduct=0;
        while (airpress(pos(ia,1)+ib,1)-startinspairpress)<=0 && ...
                (pos(ia,1)+ib)<numel(airpress)
            % determining whether the starting inspiratory pressure is higher
            % than the measured pressure
            pointthreepos= pos(ia,1)+ib;
            pointthreepress= airpress(pos(ia,1)+ib,1);
            deltapressure= abs((pointthreepress-airpress(pos(ia,1)+ib-1,1))*0.01);
            pressuretimeproduct=pressuretimeproduct + deltapressure;
            flg=1;
            ib=ib+1;
        end
        if flg==1
            % saving position of pointthree, pressure at pointthree and the
            % pressuretimeproduct in an array
            p3array(ia,1)=pointthreepos;
            p3array(ia,2)=pointthreepress;
            p3array(ia,3)=pressuretimeproduct;
            flg=0;
        else
            p3array(ia,1)=pos(ia,1);
            p3array(ia,2)=airpress(pos(ia,1));
            p3array(ia,3)=0;
            flg=0;
        end
    end
    %% 4 Identifying systolic pressure values for each breath

    %preparing respiratory indices
    matresp(:,1)=startinsp;
    matresp(:,2)=p3array(:,1);
    matresp(:,[3, 4])=startexp;

    pPART=0;
    if ~isempty(matresp)    
        sys=partsys(:,[1 2]);
        dia=partsys(:,[4 5]);
        HR= partsys(:,3);
        DP(2:size(sys,1),:)=[partsys(2:end,1) partsys(2:end,2)-partsys(2:end,5)];
        % inspiration 2
        ib=1;
        c1=0;
        c2=[0, 0, 0];
        c3=1;
        c4=1;
        flg1=0;
         for ia=1:size(matresp,1)
            while ib<size(sys,1) 
                if flg1==0 && sys(ib,1)>=matresp(ia,1) && sys(ib,1) <= matresp(ia,3)
                    flg1=ib;
                end
                if flg1>0 && sys(ib,1)>=matresp(ia,1) && sys(ib,1) <= matresp(ia,3)
                    c1=c1+1;
                end
                if sys(ib,1)>matresp(ia,3) 
                    c2=[flg1,c1,ia];
                    flg1=0;
                    c1=0;
                    break

                end
                ib=ib+1;
            end
            % 1 or more heart beats per inspiration
            if c2(2)>=1
                [tmax,tmaxp]=max(sys(c2(1):c2(1)+c2(2)-1,2));
                PAsysmaxinsp(c4,1)=sys(c2(1)+(tmaxp-1),1);
                PAsysmaxinsp(c4,2)=tmax;
                PAsysmaxinsp(c4,3)=c2(3);
                posPART2(ia,1)=ia;
                posPART2(ia,2)=PAsysmaxinsp(c4,1);
                
                posPART3(ia,1)=ia;
                posPART3(ia,2)=dia(c2(1)+(tmaxp-1),1);
                posPART3(ia,3)=DP(c2(1)+(tmaxp-1),2); %DP maxinsp
                posPART3(ia,8)=c2(1);%c2(1)+(tmaxp-1);
                % posPART3 guardar HR
                tVT2(ia,1)=ia;
                tVT2(ia,2)=0.01*sum(flow(matresp(ia,1):matresp(ia,3)-1));
                tVT2(ia,3)=matresp(ia,3)-1;
                if c2(2)==1
                    %posPART2(ia,5)=0;
                    tminPAinsp(ia,1)=ia;
                    c2=[0, 0, 0];
                else
                    [~,tminp]=min(sys(c2(1):c2(1)+c2(2)-1,2));
                    tminPAinsp(ia,1)=ia;
                    tminPAinsp(ia,2)=sys(c2(1)+(tminp-1),1);
                    tminPAinsp(ia,3)=artpress(sys(c2(1)+(tminp-1),1),1);
                    %posPART2(ia,5)=sys(c2(1)+(tminp-1),1);
                end
                c4=c4+1;
                % disp(ia)
            end
            %
            if c2(2)>=2
                [tmax,tmaxp]=max(sys(c2(1):c2(1)+c2(2)-1,2));
                [tmin,tminp]=min(sys(c2(1):c2(1)+c2(2)-1,2));
                partsysmaxinsp(c3,1)=sys(c2(1)+(tmaxp-1),1);
                partsysmaxinsp(c3,2)=tmax;
                partsysmaxinsp(c3,3)=c2(3);
                partsysmininsp(c3,1)=sys(c2(1)+(tminp-1),1);
                partsysmininsp(c3,2)=tmin;
                partsysmininsp(c3,3)=c2(3);
                posPART(ia,1)=ia;
                posPART(ia,2)=partsysmaxinsp(c3,1);
                posPART(ia,3)=partsysmininsp(c3,1);
                tVT(ia,1)=ia;
                tVT(ia,2)=0.01*sum(flow(matresp(ia,1):matresp(ia,3)-1));
                tVT(ia,3)=matresp(ia,3)-1;
                c2=[0, 0, 0];
                c3=c3+1;
            end
            
         end
                
        % expiration
        ib=1;
        c1=0;
        c2=[0, 0, 0];
        c3=1;
        flg1=0;
         for ia=1:size(matresp,1)-1
            while ib<size(sys,1) 
                if flg1==0 && sys(ib,1)>matresp(ia,3) && sys(ib,1) < matresp(ia,4)% matresp(ia+1,1)
                    flg1=ib;
                end
                if flg1>0 && sys(ib,1)>matresp(ia,3) && sys(ib,1) < matresp(ia,4)% matresp(ia+1,1)
                    c1=c1+1;
                end
                if sys(ib,1)>matresp(ia,4)%matresp(ia+1,1)
                    c2=[flg1,c1,ia];
                    flg1=0;
                    c1=0;
                    break
                end
                ib=ib+1;
            end
            %
            if c2(2)>=1
                [tmax,tmaxp]=max(sys(c2(1):c2(1)+c2(2)-1,2));
                [tmin,tminp]=min(sys(c2(1):c2(1)+c2(2)-1,2));
                PAsysmaxexp(c4,1)=sys(c2(1)+(tmaxp-1),1);
                PAsysmaxexp(c4,2)=tmax;
                PAsysmaxexp(c4,3)=c2(3);
                PAsysminexp(c4,1)=sys(c2(1)+(tminp-1),1);
                PAsysminexp(c4,2)=tmin;
                PAsysminexp(c4,3)=c2(3);
                posPART2(ia,3)=PAsysminexp(c4,1);
                posPART2(ia,4)=PAsysmaxexp(c4,1);
                SDE1(ia,1)=sys(c2(1)+1,2)-sys(c2(1),2);% difference between the first two hb during exp
                posPART3(ia,4)=dia(c2(1)+(tmaxp-1),1);
                posPART3(ia,5)=dia(c2(1)+(tminp-1),1);
                posPART3(ia,6)=DP(c2(1)+(tmaxp-1),2);%DP maxexp
                posPART3(ia,7)=DP(c2(1)+(tminp-1),2);%DP minexp
                posPART3(ia,9)=c2(1)+c2(2)-1;%c2(1)+(tminp-1);
                tVT2(ia,4)=0.01*sum(flow(matresp(ia,3):matresp(ia,4)));%(flow(matresp(ia,1):matresp(ia,3)-1));
                tVT2(ia,5)=matresp(ia,4);%matresp(ia,3)-1;
                c4=c4+1;
            end
            %
            if c2(2)>=2
                [tmax,tmaxp]=max(sys(c2(1):c2(1)+c2(2)-1,2));
                [tmin,tminp]=min(sys(c2(1):c2(1)+c2(2)-1,2));
                partsysmaxexp(c3,1)=sys(c2(1)+(tmaxp-1),1);
                partsysmaxexp(c3,2)=tmax;
                partsysmaxexp(c3,3)=c2(3);
                partsysminexp(c3,1)=sys(c2(1)+(tminp-1),1);
                partsysminexp(c3,2)=tmin;
                partsysminexp(c3,3)=c2(3);
                posPART(ia,4)=partsysmaxexp(c3,1);
                posPART(ia,5)=partsysminexp(c3,1);
                tVT(ia,4)=0.01*sum(flow(matresp(ia,3):matresp(ia,4)));
                tVT(ia,5)=matresp(ia,4);
                c2=[0, 0, 0];
                c3=c3+1;
            end
         end
        
        % airway pressure
        for ia=1:size(matresp,1)-1
            [tmax, tmaxp]=max( airpress(matresp(ia,1):matresp(ia,4),1) ); 
            posAIRP(ia,1)=matresp(ia,1)+tmaxp-1;
            posAIRP(ia,2)=tmax;
            posAIRP(ia,3)=tmax-PEEP;                % driving pressure
            RF(ia,1)=60/((matresp(ia,4)-matresp(ia,1))/100);
            % RF(ia,1)=60/((matresp(ia+1,1)-1-matresp(ia,1))/100);
        end
        % saving identified pressure values
        ib=1;
        for ia=1:size(posPART,1)
            if posPART(ia,2)~=0 && posPART(ia,4)~=0
                pPART(ib,1:5)=posPART(ia,:);
                pPART(ib,6)=posAIRP(ia,1);
                pPART(ib,7)=posAIRP(ia,3);              %
                vPART(ib,1)=pPART(ib,1);
                vPART(ib,2:5)=artpress(pPART(ib,2:5),1)';
                vPART(ib,6)=posAIRP(ia,2);              %
                vPART(ib,7)=time(pPART(ib,6),1);
                VT(ib,1)=tVT(ia,2);
                VT(ib,2)=tVT(ia,2)/posAIRP(ia,3);   % ceff
                VT(ib,3)=tVT(ia,4);
                ib=ib+1;
            end
        end
        ib=1;
        for ia=1:size(posPART2,1)
            if posPART2(ia,2)~=0 && posPART2(ia,3)~=0
                pPART2(ib,1:3)=posPART2(ia,1:3);
                pPART2(ib,4)=posAIRP(ia,1);
                pPART2(ib,5)=posAIRP(ia,3);
                pPART2(ib,6)=posPART2(ia,4);        % Pmax exp
                % pPART2(ib,7)=posPART2(ia,5);        % Pmin insp when c2~=1
                pPART3(ib,1:7)=posPART3(ia,1:7);
                SDE(ib,1)=SDE1(ia,1);
                HRRF(ib,1)=mean(HR(posPART3(ia,8):posPART3(ia,9),1));
                HRRF(ib,2)=RF(ia,1);
                HRRF(ib,3)=HRRF(ib,1)/HRRF(ib,2);
                vPART2(ib,1)=pPART2(ib,1);
                vPART2(ib,2:3)=artpress(pPART2(ib,2:3),1)';
                vPART2(ib,4)=posAIRP(ia,2);
                vPART2(ib,5)=time(pPART2(ib,4),1);
                vPART2(ib,6)=artpress(pPART2(ib,6),1);
                
                VT2(ib,1)=tVT2(ia,2);
                VT2(ib,2)=tVT2(ia,2)/posAIRP(ia,3);   % ceff
                VT2(ib,3)=tVT2(ia,4);
                minPAinsp(ib,:)=tminPAinsp(ia,:);
                ib=ib+1;
            end
        end
        for ia=5:size(HRRF,1)
            HRRF(ia,4)=mean(HRRF(ia-4:ia,1));
            HRRF(ia,5)=mean(HRRF(ia-4:ia,2));
            HRRF(ia,6)=HRRF(ia,4)/HRRF(ia,5);
        end
        %
        if size(pPART,2)==1
            pPART=zeros(1,7);
            pPART2=zeros(1,7);
            pPART3=zeros(1,7);
            vPART=zeros(1,7);
            vPART2=zeros(1,7);
            minPAinsp=zeros(1,3);
            VT=zeros(1,3);
            VT2=zeros(1,3);
            partsysmaxinsp =zeros(1,3);
            partsysmaxexp=zeros(1,3);
            partsysmininsp=zeros(1,3);
            partsysminexp=zeros(1,3);
            PPVd3=zeros(1,4);
            PPVd4=zeros(1,4);
            SDE2=zeros(1,3);
            
        elseif plotonoff==1
            figure
            plot(time,artpress,'r-','linewidth',2)
            hold on
            plot(time,10*airpress,'k:','linewidth',2)
            
            plot(time(pPART2(:,2),1), artpress(pPART2(:,2),1),'rs','linewidth',1,'markersize',16,'markerfacecolor','r')
            plot(time(pPART2(:,3),1), artpress(pPART2(:,3),1),'bs','linewidth',2,'markersize',16)%,'markerfacecolor','g')
            plot(time(pPART2(:,6),1), artpress(pPART2(:,6),1),'bs','linewidth',1,'markersize',16,'markerfacecolor','b')
            plot(time(pPART2(:,4),1), 10*airpress(pPART2(:,4),1),'k*','linewidth',2,'markersize',12)
            
            for id=1:size(minPAinsp,1)
                if minPAinsp(id,2)>0
                    plot(time(minPAinsp(id,2),1), artpress(minPAinsp(id,2),1),'rs','linewidth',2,'markersize',16)%,'markerfacecolor','r')
                    
                end
            end
            
%             plot(time(pPART3(2:end,2),1), artpress(pPART3(2:end,2),1),'ro','linewidth',1,'markersize',12,'markerfacecolor','r')
%             plot(time(pPART3(2:end,4),1), artpress(pPART3(2:end,4),1),'bo','linewidth',1,'markersize',12,'markerfacecolor','b')
%             plot(time(pPART3(2:end,5),1), artpress(pPART3(2:end,5),1),'bo','linewidth',2,'markersize',12)%,'markerfacecolor','c')
            
            plot(time,(flow*0.06)+70, 'b--','linewidth',2)
            plot(time(partsys(3:end,1),1),artpress(partsys(3:end,1),1),'ks','linewidth',2)
            plot(time(partsys(3:end,4),1),artpress(partsys(3:end,4),1),'ks','linewidth',2)
            
%             plot(time(startinsp(:,1),1),9*airpress(startinsp(:,1)),'g*','linewidth',2,'markersize',12)
%             plot(time(startexp(:,1),1),9*airpress(startexp(:,1)),'m*','linewidth',2,'markersize',12)
%             plot(time(startinsp(:,1),1),(flow(startinsp(:,1))/20)+70,'g*','linewidth',2,'markersize',12)
%             plot(time(startexp(:,1),1),(flow(startexp(:,1))/20)+70,'m*','linewidth',2,'markersize',12)
            
            title(['Patient:' num2str(patno) ' chunk:' num2str(chunki) ' PS levels:' num2str(tlab)]) 
            hold off
            PPVd3=zeros(1,4);
            PPVd4=zeros(1,4);
            SDE2=zeros(1,3);
            %
        elseif plotonoff==2
            figure
            plot(time,artpress,'r-','linewidth',2)
            hold on
            plot(time,10*airpress,'k:','linewidth',2)       % pressre times 10
            plot(time,(flow*0.06)+70, 'b--','linewidth',2) % flow in L/min +70
            ik=1;
            for ic=3:size(HRRF,1)
                cond=0;
                if pPART3(ic,3)>minDP && pPART3(ic,3)<maxDP && pPART3(ic,6)>minDP && pPART3(ic,6)<maxDP && pPART3(ic,7)>minDP && pPART3(ic,7)<maxDP
                    cond=1;
                end
                if HRRF(ic,6)>3.4 && VT2(ic,1)>0 && cond==1% 
                    plot(time(pPART2(ic,2),1), artpress(pPART2(ic,2),1),'rs','linewidth',1,'markersize',16,'markerfacecolor','r')
                    plot(time(pPART2(ic,3),1), artpress(pPART2(ic,3),1),'bs','linewidth',2,'markersize',16)%,'markerfacecolor','g')
                    plot(time(pPART2(ic,6),1), artpress(pPART2(ic,6),1),'bs','linewidth',1,'markersize',16,'markerfacecolor','b')
                    plot(time(pPART2(ic,4),1), 10*airpress(pPART2(ic,4),1),'k*','linewidth',2,'markersize',12)
                    %line([time(pPART2(ic,2),1) time(pPART2(ic,3),1)],[artpress(pPART2(ic,2),1) artpress(pPART2(ic,3),1)],'color','m','LineStyle',':','linewidth',3)
                    PPVd3(ik,1)=pPART2(ic,2);
                    PPVd3(ik,2)=artpress(pPART2(ic,2),1)-artpress(pPART2(ic,3),1); %d3=maxinsp-minexp
                    PPVd3(ik,3)=pPART2(ic,5);
                    PPVd3(ik,4)=VT2(ic,1);
                    %line([time(pPART2(ic,2),1) time(pPART2(ic,6),1)],[artpress(pPART2(ic,2),1) artpress(pPART2(ic,6),1)],'color','g','LineStyle',':','linewidth',3)
                    if SDE(ic,1)<0
                        line([time(pPART2(ic,2),1) time(pPART2(ic,3),1)],[artpress(pPART2(ic,2),1) artpress(pPART2(ic,3),1)],'color','m','LineStyle',':','linewidth',3)
                        cond2=0;
                        SDE2(ik,1)=SDE(ic,1);
                        SDE2(ik,2)=time(pPART2(ic,2),1);
                        SDE2(ik,3)=(artpress(pPART2(ic,3),1)-artpress(pPART2(ic,2),1))/(time(pPART2(ic,3),1)-time(pPART2(ic,2),1));
                    else
                        cond2=1;
                    end
                    if minPAinsp(ic,2)>0
                        plot(time(minPAinsp(ic,2),1), artpress(minPAinsp(ic,2),1),'rs','linewidth',2,'markersize',16)
                        if cond2==1
                            line([time(minPAinsp(ic,2),1) time(pPART2(ic,6),1)],[artpress(minPAinsp(ic,2),1) artpress(pPART2(ic,6),1)],'color','g','LineStyle',':','linewidth',3)
                            SDE2(ik,1)=SDE(ic,1);
                            SDE2(ik,2)=time(minPAinsp(ic,2),1);
                            SDE2(ik,3)=(artpress(pPART2(ic,6),1)-artpress(minPAinsp(ic,2),1))/(time(pPART2(ic,6),1)-time(minPAinsp(ic,2),1));
                        end
                        PPVd4(ik,1)= minPAinsp(ic,2);
                        PPVd4(ik,2)= artpress(minPAinsp(ic,2),1)-artpress(pPART2(ic,6),1); %d4=mininsp-maxexp
                        PPVd4(ik,3)= pPART2(ic,5);
                        PPVd4(ik,4)=VT2(ic,1);
                        ik=ik+1;
                    else
                        if cond2==1
                            line([time(pPART2(ic,2),1) time(pPART2(ic,6),1)],[artpress(pPART2(ic,2),1) artpress(pPART2(ic,6),1)],'color','g','LineStyle',':','linewidth',3)
                            SDE2(ik,1)=SDE(ic,1);
                            SDE2(ik,2)=time(pPART2(ic,2),1);
                            SDE2(ik,3)=(artpress(pPART2(ic,6),1)-artpress(pPART2(ic,2),1))/(time(pPART2(ic,6),1)-time(pPART2(ic,2),1));
                        end
                        PPVd4(ik,1)= pPART2(ic,2);
                        PPVd4(ik,2)= artpress(pPART2(ic,2),1)-artpress(pPART2(ic,6),1); %d4=mininsp-maxexp
                        PPVd4(ik,3)= pPART2(ic,5);
                        PPVd4(ik,4)=VT2(ic,1);
                        ik=ik+1;
                    end

                end
                if ik==1
                    PPVd3=zeros(1,4);
                    PPVd4=zeros(1,4);
                    SDE2=zeros(1,3);
                end
            end
            plot(time(partsys(3:end,1),1),artpress(partsys(3:end,1),1),'ks','linewidth',2)
            plot(time(partsys(3:end,4),1),artpress(partsys(3:end,4),1),'ks','linewidth',2)
            title(['Patient:' num2str(patno) ' chunk:' num2str(chunki) ' PS levels:' num2str(tlab)]) 
            hold off
%             figure
%             hold on
%             plot(time(pPART3(2:end,2),1), HRRF(2:end,1), 'b.')
%             plot(time(pPART3(2:end,2),1), HRRF(2:end,2), 'g.')
%             plot(time(pPART3(5:end,2),1), HRRF(5:end,4), 'b-')
%             plot(time(pPART3(5:end,2),1), HRRF(5:end,5), 'go')
%             
%             title(['Patient ' num2str(patno) ' PS levels: ' num2str(tlab)]) 
%             hold off
%             figure
%             hold on
%             plot(time(pPART3(2:end,2),1), HRRF(2:end,3), 'r.')
%             plot(time(pPART3(5:end,2),1), HRRF(5:end,6), 'ro')
        end
    else
        pPART=zeros(1,7);
        pPART2=zeros(1,7);
        pPART3=zeros(1,7);
        vPART=zeros(1,7);
        vPART2=zeros(1,7);
        minPAinsp=zeros(1,3);
        VT=zeros(1,3);
        VT2=zeros(1,3);
        partsysmaxinsp =zeros(1,3);
        partsysmaxexp=zeros(1,3);
        partsysmininsp=zeros(1,3);
        partsysminexp=zeros(1,3);
        PPVd3=zeros(1,4);
        PPVd4=zeros(1,4);
        SDE2=zeros(1,3);
    end
    %%
else
    startinsp=0;
    startexp=0;
    p3array=0;
    pPART=zeros(1,7);
    pPART2=zeros(1,7);
    pPART3=zeros(1,7);
    vPART=zeros(1,7);
    vPART2=zeros(1,7);
    minPAinsp=zeros(1,3);
    VT=zeros(1,3);
    VT2=zeros(1,3);
    partsysmaxinsp =zeros(1,3);
    partsysmaxexp=zeros(1,3);
    partsysmininsp=zeros(1,3);
    partsysminexp=zeros(1,3);
    PPVd3=zeros(1,4);
    PPVd4=zeros(1,4);
    SDE2=zeros(1,3);
end
end