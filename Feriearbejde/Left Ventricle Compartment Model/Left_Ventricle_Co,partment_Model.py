# -*- coding: utf-8 -*-
"""
Created on Tue Aug  1 10:07:45 2023

@author: Lasse
"""
#Imports
import plotly.express as px
from plotly.offline import plot, iplot, init_notebook_mode
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import math #For eulers number
import matlab.engine #ODE15s solver
import numpy as np
import pandas as pd

#%% Start Matlab Engine
eng = matlab.engine.start_matlab()


#%% Parameters
# =============================================================================
# 
# #Volume at t=0
# #V0 = 0 #m^-3
# eng.workspace['V0'] = eng.double(0)
# #End systolic elastance
# Ees = 100e6 #N/m^5
# eng.workspace['Ees'] = eng.double(100e6)
# 
# 
# #Diastole volume
# Vd = 0 #m^-3
# eng.workspace['Vd'] = Vd
# 
# #Pressure at t=0
# P0 = 10 #N/m^2
# eng.workspace['P0'] = P0
# #?lambda?
# lam = 33000 #m^-3
# eng.workspace['lam'] = lam
# 
# #Pressure at pulmonary vein
# P1=1000 #N/m^2
# eng.workspace['P1'] = P1
# #Pressure at aorta
# P3=2000 #N/m^2
# eng.workspace['P3'] = P3
# 
# #Resistance mitral valve
# R1 = 6e6 #Ns/m^5
# eng.workspace['R1'] = R1
# #Resistance aortic valve
# R2 = 6e6 #Ns/m^5
# eng.workspace['R2'] = R2
# 
# #Cardiac Driver Function
# N=1
# A=1
# B=80 #sec^-2
# C=0.27 #sec
# 
# eng.workspace['N'] = N
# eng.workspace['A'] = A
# eng.workspace['B'] = B
# eng.workspace['C'] = C
# 
# print(eng.workspace['N'])
# =============================================================================





#%%Governing equations - IMPLEMENTED IN MATLAB

# def Pes(V: float) -> float:
#     """

#     Returns
#     -------
#     End Systolic Pressure.

#     """
#     Pes = Ees*(V-Vd)
    
#     return Pes

# def Ped(V: float) -> float:
#     """
#     Returns
#     -------
#     End Diastolic Pressure
    
#     """
#     Ped = P0*(pow(math.e, lam*(V-V0))-1)
    
#     return Ped
    
# def Plv(V: float, t: int) -> float:
#     """
#     Returns
#     -------
#     Left Ventricle Pressure
#     """
#     def drive_fun(t: int) -> float:
#         """
#         Returns
#         -------
#         Cardiac Driver Function
#         """
        
#         A*pow(math.e,-B*(t-C)**2)
    
#     Plv = drive_fun(t)*Pes(V)+(1-drive_fun(t))*Ped(V)
    
#     return Plv

# def Q(P2: float,direction: str) -> float:
#     if direction == "in":    
#         Qin = (P1-P2)/R1
        
#         return Qin
        
#     if direction == "out":
#         Qout = (P2-P3)/R2
        
#         return Qout

# def diff_volume(Qin: float, Qout: float) -> float:
#     dV = Qin-Qout
    
#     return dV
    

        
    
        



#%% Ventricle Model - IMPLEMENTED IN MATLAB

# def ventricle_model(t: float) -> float:
    
#     P2 = Plv(V0, t) #Pressure in the left ventricle
#     Qin = Q(P2,"in") #Flow into the ventricle
#     Qout = Q(P2,"out") #Flow out of the ventricle
    
#     dV = diff_volume(Qin,Qout) #Calculate the change in volume based on pressure and flow
    






#%% Run compartment model with ODE solver


eng.workspace['V0'] = eng.double(0.00001)

eng.eval("tspan = [0:0.01:1.8]';",nargout=0)
[t,V] = eng.eval('ode15s(@left_ventricle,tspan,V0)',nargout=2)

#%% Extract data from matlab workspace to Spyder
left_ventricle = pd.DataFrame(index = np.arange(len(t._data)), columns= ['time','volume'])

left_ventricle['time'] = t._data
left_ventricle['volume'] = V._data
left_ventricle['volume'] = left_ventricle['volume']*1000000

fig = px.scatter(data_frame=left_ventricle, x='time',y='volume')
plot(fig)



# =============================================================================
# eng.eval('tspan = [0 5];',nargout=0)
# eng.workspace['y0'] = eng.double(0)
# [t,y] = eng.eval('ode45(@(t,y) 2*t, tspan, y0);',nargout=2)
# 
# fig = px.scatter(x=t._data, y=y._data)
# plot(fig)
# 
# eng.eval('plot(t,y)')
# =============================================================================



































