import numpy as np

def cal_Bz_using_BiotSavart(X, Y, Z, current, coil_trace):
    mu0 = 4*np.pi*1e-7

    x_P, y_P, z_P = coil_trace[0], coil_trace[1], coil_trace[2]
    PkM3 = X[:,:,:,np.newaxis]-x_P[np.newaxis,np.newaxis,np.newaxis,:]