# -*- coding: utf-8 -*-
"""
Created on Mon Jul 31 12:20:57 2023

@author: Lasse
"""

# Find specific excercise description in C:\Users\Lasse\OneDrive\Skrivebord\Speciale\Feriearbejde

#Imports
import plotly.express as px
from plotly.offline import plot, iplot, init_notebook_mode
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np

#%% Parameters
#Resistance
R = 20 #N*s/m^5

#Pressure downstream
P2 = 40 #N/m^2
#Ventricle elastic properties
E = 100 #N/m^5
V0 = 2 #m^3
T = np.arange(0,5,0.01)
tstep = 0.01

#%% equations

def dVdt(t,V):
    P1 = E*V+V0
    Q = (P1-P2)/R
    dVdt = (-1)*Q
    
    return P1, Q, dVdt
    
    

#Create array to hold volume
V = [None]*len(T)
P1 = [None]*len(T)
Q = [None]*len(T)

V[0] = V0


for t in range(len(T)):
    P1_temp, Q_temp, dVdt_temp = dVdt(t,V[t])
    
    
    P1[t] = P1_temp
    Q[t] = Q_temp    

    
    if (t<len(T)-1):
        print(t)
        V[t+1] = V[t]+dVdt_temp*tstep

#%% Plots
trace1 = go.Scatter(#x=esoData.index, 
                   y=P1,
                   mode='markers+text',
                   )

trace2 = go.Scatter(#x=esoData.index, 
                   y=Q,
                   mode='markers+text'
                   )

trace3 = go.Scatter(#x=temp_df.index, 
                   y=V,
                   mode='markers+text',
                   #text=temp_df[flow_peak]
                   )


fig = make_subplots(rows=2,cols=2,subplot_titles=("Pressure","Volume","Flow"))
fig.add_trace(trace1,row=1,col=1)
fig.add_trace(trace2,row=2,col=1)
fig.add_trace(trace3,row=1,col=2)

# =============================================================================
# fig['layout'].update(height = 600, width = 800, title = "Extracting insp- and expiratory flow",xaxis=dict(
#       tickangle=-90
#     ),
#     yaxis_title="P (mmH2O)",
#     xaxis_title="Time (S" + comp_halp.get_super('-2')+')')
# 
# =============================================================================

# =============================================================================
# fig.update_layout(
#     title={
#         'text': "Timeframes with Pmus = ~0",
#         'y':0.95,
#         'x':0.5,
#         'xanchor': 'center',
#         'yanchor': 'top'})
# plot(fig)    
# =============================================================================

#fig = px.scatter(esoData,x=esoData.index,y=esoData[ModifiedPeso])
plot(fig)


