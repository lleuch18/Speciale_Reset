function [pao_plot,ppl_plot,flow_plot,V_plot,pvent_plot,pmus_plot] = plots(pao,ppl,flow,v,pvent,pmus)

pao_plot = false;
ppl_plot = false;
flow_plot = false;
V_plot = false;
pvent_plot = false;
pmus_plot = false;

if pao == true
pao_plot = true;
end

if ppl == true
ppl_plot = true;
end

if flow == true
flow_plot = true;
end

if v == true;
V_plot = true;
end

if pvent == true
pvent_plot = true;
end

if pmus == true
pmus_plot = true;
end
end

