function Ppl = Ppl(Start_Ppl,End_Ppl,nDt)
%Calculates a vector for Ppl at inspiration and expiration
%Uses the patients average Inspiratory/Expiratory time over a range of
%breaths

%Parameters
%Start_Ppl:  Ppl at inspiratory start
%End_Ppl: Ppl at expiratory start

%Assumptions
%Ppl increases and decreases gradually during respiration
%Patients inspiratory- and expiratory times remain stationary over a number
%of breaths

%PseudoKode
%1. Insp/Expiratory_time findes for hver chunk (antages konstant)
%2. Beregn Start_ppl for breath
%3. Beregn Slut_ppl for breath


global P

%Insp_Ppl = [Start_Ppl:Insp_Time:End_Ppl]
%Exp_Ppl = [End_Ppl:Exp_Time:End_Ppl]

Ppl = linspace(Start_Ppl,End_Ppl,nDt)

end


%A = Amplitude
%f = Frequency [Hz]
%Period = Length of 1 cycle [s]
%t=time of simulation

%f = 1/period;

%Pit = A*sin(2*pi*f*t)+Offset;
