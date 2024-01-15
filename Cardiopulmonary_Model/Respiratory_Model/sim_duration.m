function sim_duration()
%pre-calculates the driver function of the system, in order to solve
%inconsistensies with ODE113's timesteps

%Function added to reduce verboseness

global P

t = [0:0.002:P.resp.Te+P.resp.Ti]; %Full Duration

cnt = 1;

P.resp.Pao = zeros(length(t),1);

for i = 1:length(t);
    P.resp.Pao(cnt) = Activation_Function(t(i));
    cnt = cnt + 1;

end
end

