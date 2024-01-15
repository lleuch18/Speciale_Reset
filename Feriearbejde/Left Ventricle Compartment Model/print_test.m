clc
clear all

% Trækker 600 fra for a resette tstep. Ganger med t/600 for at
        % reset altid er konsistent med realtid PROBLEM: sker kun 1 gang
        % hvert 600ms - alle andre tidspunkter er tstep = t
        %tstep = tstep-(600*(t/600))

test = [0:0.01:5]'

