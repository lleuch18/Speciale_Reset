function [dVdt] = left_ventricle(t,V)

    %Matlab implementation of the left ventricle model
    %The model is structured as an ordinary differential equation, and solved
    %using Matlabs ODE solver.
    %Hence, a set of equations are defined, which aid in calculating the
    %time-differential of volume in the compartment.
    
%   V = double(V);
%   t = double(t);

    %End systolic elastance
    Ees = double(100e6); %N/m^5
    %Diastole volume
    Vd = double(0); %m^-3
    %V0 for calculation purposes (V0 is initial condition for ODE solver,
    %but also used in calculations)
    V0_calc = double(10); %m^-3
    %Pressure at t=0
    P0 = double(10); %N/m^2 converted to mmHg
    %?lambda?
    lam = double(33000); %m^-3
    
    %Pressure at pulmonary vein
    P1=double(1000); %N/m^2
    %Pressure at aorta
    P3=double(2000); %N/m^2
    
    %Resistance mitral valve
    R1 = double(6e6); %Ns/m^5
    %Resistance aortic valve
    R2 = double(6e6); %Ns/m^5
    
    %Cardiac Driver Function
    N=double(1);
    A=double(1);
    B=double(80); %sec^-2
    C=double(0.27); %sec
    
    
    

    %End-Systolic Pressure
    Pes = double(Ees*(V-Vd));
    Pes

    %End-Diastolic pressure
    Ped = double(P0*(exp(lam*(V-V0_calc))-1));
    %fprintf("Ped is")
    %class(Ped)


    %Pressure in the left ventricle. The cardiac driver function simulates
    %activation of the myocardium.
    Plv = double(Pes+(1-(A*exp(-B*(t-C)^2))));
    %fprintf("Plv is")
    Plv

    %Blood flow in- and out of the left ventricle
    
    Qin = double((P1-Plv)/R1);
%     fprintf("Qin is")
%     Qin
    Qout = double((Plv-P3)/R2);
%     fprintf("Qout is")
%     Qout

    %Change in volume at each timestep.
    dVdt = double((Qin-Qout)*1000);
    fprintf("dVdt is")
    dVdt

    %fprintf("V is")
    %class(V)

    






