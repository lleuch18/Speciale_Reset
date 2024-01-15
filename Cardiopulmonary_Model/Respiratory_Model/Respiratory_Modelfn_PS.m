function Respiratory_Modelfn(Ppl0,start_time,end_time,chunk,breath)
%Computes the system of equations governing the equation of motion as a
%continious time derivative, controlled by driver function Pao
%   Detailed explanation goes here

global P
%% Plots
%[Pao_plot,Ppl_plot,flow_plot,V_plot,Pvent_plot,Pmus_plot] = plots(1,1,1,1,1,1);

%plot_on = true %Switch on/off for all plots

disp(['P.resp.R:', num2str(P.resp.R)])
P.resp.breath_cnt = 0;  
disp(['PS:', num2str(P.resp.PS),'PmusSet:',num2str(abs(P.resp.PmusSet))])
if P.resp.PS > abs(P.resp.PmusSet)
    disp('RUN PPV')
    positive_pressure_ventilation(Ppl0,start_time,end_time,chunk,breath)
else
     disp('RUN NPV')
     negative_pressure_ventilation(Ppl0,start_time,end_time,chunk,breath)
end



disp('Simulation Done')
%disp(['Pao lgth:',num2str(length(P.resp.Pao))])

%{
if plot_on
    
    if Pao_plot
    figure(1)
    plot(P.resp.Pao)
    title('Pao')
    ylabel('Pao (cmH2O)')
    xlabel('Time (S)')
    end
    
    if Ppl_plot
    figure(2)
    plot(P.resp.Ppl)
    title('Ppl')
    ylabel('Ppl (cmH2O)')
    xlabel('Time (S)')
    end
    
    if flow_plot
    figure(3)
    plot(P.resp.flow);%*60 for debugging purpose
    title('flow')
    ylabel('flow (L/min)')
    xlabel('Time (S)')
    end
    
    if V_plot
    figure(4)
    plot(P.resp.V)
    title('V')
    ylabel('V (L)')
    xlabel('Time (S)')
    %yticks([0,0.5,1,1.5,2,2.5,3,3.5,4])
    %yline((P.resp.CL*P.resp.PEEP)*10^-3)
    end
    
    if Pvent_plot
    figure(5)
    plot(P.resp.Pvent)
    title('Pvent')
    ylabel('P (cmH2O)')
    xlabel('Time (S)')
    end
    
    if Pmus_plot
    figure(6)
    plot(P.resp.Pmus)
    title('Pmus')
    ylabel('P (cmH2O)')
    xlabel('Time (S)')
    end
end
%}



end

