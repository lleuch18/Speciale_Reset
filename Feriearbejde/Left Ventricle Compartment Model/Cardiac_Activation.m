function [e] = Cardiac_Activation(t)

    %Cardiac Driver Function
    %N=double(1);
    A=double(1);
    B=double(80); %sec^-2
    C=double(0.27); %sec

    e = (A*exp(-B*(t-C)^2));
end


 