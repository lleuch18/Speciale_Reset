%% flow and paw signals
function [insp, exp]=start_ie2(flow1)
% ia=2;
% flow1=flowchunk{ia};
% % 
%% inspiratory / expiratory flow  // determining inspiratory/expiratory VT
% added: expiratory flow end point and couple of restricions for low VTe or
% VTi.
n=size(flow1,1);
flow1(:,[3,4])=zeros(n,2);
for ib=1:n
    if flow1(ib,1)>0
        flow1(ib,3)=flow1(ib,1);
    else
        flow1(ib,4)=flow1(ib,1);
    end
end
vts=zeros(n,2);
for ib=2:n
    if flow1(ib,3)~=0
        vts(ib,1)=vts(ib-1,1)+0.01*flow1(ib,3);
    end
    if flow1(ib,4)~=0
        vts(ib,2)=vts(ib-1,2)-0.01*flow1(ib,4);
    end
end
% figure
% hold on
% plot(vts(:,1))      % insp
% plot(vts(:,2),'r')  % exp
% identification of inspiration
ib=1;
temp1=0;
brthi=zeros(1,3);
ic=0;
while ib<=n
    if vts(ib,1)>0 && temp1==0  % insp
        ic=ic+1;
        brthi(ic,1)=ib;
        ib=ib+1;
        temp1=1;
    elseif vts(ib,1)>0 && temp1==1
        brthi(ic,2)=ib;
        brthi(ic,3)=vts(ib,1);
        ib=ib+1;
    elseif vts(ib,1)==0
        temp1=0;
        ib=ib+1;
    end
end
brthi(:,4)=ones(size(brthi,1),1);
%% identification of expiration
ib=brthi(1,2);
ic=1;
while ib==0 && size(brthi,1)>1% ic<=numel(brthi)
    ib=brthi(1+ic,2);
    ic=ic+1;
end
 
temp1=0;
brthe=zeros(1,3);
ic=0;
while ib<=n && size(brthi,1)>1
    if vts(ib,2)>0 && temp1==0
        ic=ic+1;
        brthe(ic,1)=ib;
        ib=ib+1;
        temp1=1;
    elseif vts(ib,2)>0 && temp1==1
        brthe(ic,2)=ib;
        brthe(ic,3)=vts(ib,2);
        ib=ib+1;
    elseif vts(ib,2)==0 %&& ic~=0
        temp1=0;
        ib=ib+1;
    end
    if ib==n
        break
    end
end
brthe(:,4)=zeros(size(brthe,1),1);
%% identify start / end for each breathing cycle
% criteria: 
% * Vt insp>200 = start
% * Vt exp> 200 = exp
% * also considers flow fluctuation afer inspiration
ia=0;
ic=1;
while ia<=size(brthi,1)-1 && size(brthi,1)>1
    ia=ia+1;
    if brthi(ia,2)>0
        brthi2(ic,:)=brthi(ia,:);
        ic=ic+1;
    end
end
ia=0;
ic=1;
while ia<=size(brthe,1)-1 && size(brthi,1)>1
    ia=ia+1;
    if brthe(ia,2)>0
        brthe2(ic,:)=brthe(ia,:);
        ic=ic+1;
    end
end
if size(brthi,1)==1
    brthi2=brthi;
    brthe2=brthe;
end
temp=[brthi2; brthe2];
temp=sortrows(temp,1);
%%
n= size(temp,1);
ia=1;
ic=1;
while ia<=n-5 && size(temp,1)>2
    % 
    if temp(ia,3)>200 && temp(ia,4)==1 % && (flow1(temp(ia,2)+10,1)>0 && flow1(temp(ia,2)+15,1)>0)
        insp(ic,1)=temp(ia,1);
        if temp(ia+1,3)>200 && temp(ia+1,4)==0 % 
            % consider that VT may had been VTexp<200
            exp(ic,1)=temp(ia+1,1);
            exp(ic,2)=temp(ia+1,2);
            ia=ia+2;
        else
            %* insp followed by short exp and insp VTe>VTi then exp
            %* insp followed by short exp ***********
            if temp(ia+1,3)<200 && temp(ia+1,4)==0 && temp(ia+2,4)==1 && temp(ia+2,3)>200 %check!
                %disp(temp(ia+1,3));disp(ia)
                exp(ic,1)=temp(ia+1,1);
                exp(ic,2)=temp(ia+1,2);
                ia=ia+2;
            %* insp followed by short exp and insp VTe>VTi then exp
            elseif temp(ia+1,3)<200 && temp(ia+1,4)==0 && temp(ia+1,3)>temp(ia+2,3)... % && temp(ia+2,3)>200
                    && temp(ia+2,4)==1 && temp(ia+3,4)==0
                exp(ic,1)=temp(ia+1,1);     % % %
                exp(ic,2)=temp(ia+3,2);
                ia=ia+4;     % % %3
            %* insp followed by short exp and insp VTe<VTi then exp
            elseif temp(ia+1,3)<200 && temp(ia+1,4)==0 && temp(ia+1,3)<temp(ia+2,3)... % && temp(ia+2,3)>200
                    && temp(ia+2,4)==1 && temp(ia+3,4)==0 && temp(ia+2,3)<200
                exp(ic,1)=temp(ia+3,1);     % % %2
                exp(ic,2)=temp(ia+3,2);
                ia=ia+4;     % % %3
            
            %* insp followed by short interruption
            elseif temp(ia+1,3)<200 && temp(ia+1,4)==1 && temp(ia+1,1)-temp(ia,2)<10 ...
                    && temp(ia+2,3)>200 
                exp(ic,1)=temp(ia+2,1);
                exp(ic,2)=temp(ia+2,2);
                ia=ia+3;
            else % regresar ic!
                ic=ic-1;
% %                 exp(ic,1)=insp(ic,1)+10;
                ia=ia+1;
            end
            %ia=ia+1;
        end
        ic=ic+1;
        %ia=ia+1;
    elseif (temp(ia,3)<200 && temp(ia,4)==1 && flow1(temp(ia,2)+10,1)==0 && ia>1) ... % +1
            || (flow1(temp(ia,2)+10,1)==0 && flow1(temp(ia,2)+15,1)==0 && ia>1)
        insp(ic,1)=temp(ia-1,2)+1;
        exp(ic,1)=insp(ic,1)+10;
        exp(ic,2)=insp(ic,1)+11;
        ic=ic+1;
        ia=ia+1;
    else 
        ia=ia+1;
    end
    
end
if size(temp,1)==2
    insp=1;
    exp =[1, 1];
end
end