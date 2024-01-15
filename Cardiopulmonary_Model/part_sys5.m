%% Function for determining sytolic pressure
% sens is a sensitivity parameter. 
% *sens =10 for all patients but patient 5.
% *sens =15 for patient 5
% partsys is an array with 5 columns:
% 1 position of Partsys
% 2 value of Partsys
% 3 instantaneous heart rate 
% 4 position of Partdia
% 5 value of Partdia
function partsys=part_sys5(artpress0,sens)
%%
% % i=1;
% % artpress0=artpresschunk{i};
% % sens=10;
%
for ia=2:numel(artpress0)-1
    artpress(ia,1)=(0.25*artpress0(ia-1,1))+(0.5*artpress0(ia,1))+(0.25*artpress0(ia+1,1));
end
num=size(artpress,1)-1;
d10artpress(:,1)=zeros(num,1);
for ia=10:numel(artpress)
    d10artpress(ia,1)=artpress(ia,1)-artpress(ia-9,1);
end
%
flg1=0;
% flg2=0;
ia=10;
ic=1;
% *********** 
while ia<=num-5
    temp0=d10artpress(ia,1);                        % 
    if temp0>sens && d10artpress(ia+1,1)>temp0 ...  % 
            && d10artpress(ia+2,1)>temp0 && d10artpress(ia+3,1)>temp0 ...
            && d10artpress(ia+4,1)>temp0 && d10artpress(ia+5,1)>temp0 && flg1==0
        flg1=ia;
        temp3(ic,1)=ia;
        ic=ic+1;
%         temp2= artpress(ia,1);
        ia=ia+5;
    else
        ia=ia+1;
    end
    
    if flg1>0
        ia=ia+1;
        if temp0<0 && d10artpress(ia+2,1)<0
            flg1=0;
        end
    end
    
end

if ic<10
    partsys=[1 1 1 1 1];
    disp('error')
%end
else %size(partsys,1)>1
    for ia=2:size(temp3,1)
        [t1, t2]=max(artpress0(temp3(ia-1,1):temp3(ia,1)));
        
        partsys(ia,1)=temp3(ia-1,1)+t2-1;
        partsys(ia,2)=t1;%artpress(temp3(:,2));
        partsys(ia,3)=6000/(partsys(ia,1)-partsys(ia-1,1));
    end
end
% diastolic pressure
if size(partsys,1)>1
    for ia=3:size(partsys,1)
        [t1, t2]=min(artpress0(partsys(ia-1,1):partsys(ia,1)));%:artpress(temp3(ia,2)),1);
        partsys(ia,4)=partsys(ia-1,1)+t2-1;
        partsys(ia,5)=t1;
    end

end
    
end