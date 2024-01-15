function intrathoracic_model(Ppl,alpha,chunk,start_index,b)
%Intrathoracic pressure model - Simulating the transfer of intrathoracic
%pressure to the cavities of the heart
global P

%Pseudocode
%1. Input Ppl
%2. Add transmural pressure to cardiovascular system

    
    if isfield(P.PPV{chunk},'pu_art_post') == 0    
        P.PPV{chunk}.pu_art_post = zeros(length(P.PPV{chunk}.pu_art_pre),1);
    end


for ia = 1:length(Ppl)
    %Adds Ppl scaled by factor alpha to every entry in the pu_art calculations
    P.PPV{1}.pu_art_post(ia+start_index) = P.PPV{chunk}.pu_art_pre(ia+start_index)+(alpha*Ppl(ia)*round(0.736,3)); %Ppl stored in cmH2O, converted to mmHg for BP measurements
end
disp('Transthoracic simulation done')
