function [dVdt] = left_ventricle(t,V)
    



    %Matlab implementation of the left ventricle model
    %The model is structured as an ordinary differential equation, and solved
    %using Matlabs ODE solver.
    %Hence, a set of equations are defined, which aid in calculating the
    %time-differential of volume in the compartment.
    
%     V = double(V);
%     t = double(t);

    %End systolic elastance (Values found through slides)
    Ees = double(100e6);%double(0.75); %N/m^5
    %Diastole volume
    Vd = double(0); %m^-3
    %V0 for calculation purposes (V0 is initial condition for ODE solver,
    %but also used in calculations)
    V0_calc = double(10);%double(10e-6); %m^-3 converted to mL
    %Pressure at t=0 (found through slides)
    P0 = double(10);%double(0.075); %N/m^2 converted to mmHg
    %?lambda? (original lambda reduced by factor 1000)
    lam = double(33000);%double(3.3e-5); %m^-3
    
    %Pressure at pulmonary vein
    P1=double(1000);%double(7.5); %N/m^2 converted to mmHg
    %Pressure at aorta
    P3=double(2000);%double(15); %N/m^2 converted to mmHg
    
    %Resistance mitral valve
    R1 = double(6e6);%double(0.75); %Ns/m^5 converted to mmHg*s/mL
    %Resistance aortic valve
    R2 = double(6e6);%double(0.75); %Ns/m^5 converted to mmHg*s/mL
    
    
    
    
    

    %End-Systolic Pressure
    Pes = double(Ees*(V-Vd));
    %Pes

    %End-Diastolic pressure
    Ped = double(P0*(exp(lam*(V-V0_calc))-1));
    %fprintf("Ped is")
    %class(Ped)


    %Pressure in the left ventricle. The cardiac driver function simulates
    %activation of the myocardium.
    heartbeat = 0;
    %Check if we reached heartbeat
    if t-rem(t,0.6) > 0
        %Calculate time above 600ms
        surplus = rem(t,0.6);
        %Calculate which heartbeat function is at
        heartbeat = heartbeat + ((t-surplus)/0.6);
    end
    %Reset tstep at every heartbeat    
    tstep = t-(0.6*heartbeat);
    Plv = double(Cardiac_Activation(tstep)*Pes+(1-Cardiac_Activation(tstep))*Ped);
    %fprintf("Plv is")
    %Plv

    %Blood flow in- and out of the left ventricle
    
    Qin = double((P1-Plv)/R1);
    if Qin > 0
        fprintf("happened at time")
        t
    end
%     Qin
    Qout = double((Plv-P3)/R2);
%     fprintf("Qout is")
%     Qout

    %Change in volume at each timestep.
    dVdt = double((Qin-Qout));
    %fprintf("dVdt is")
   % dVdt

    %fprintf("V is")
    %class(V)
    

    






