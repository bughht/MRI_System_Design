import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat

coil_trace = loadmat('coil_trace.mat')['ch29_coil_array_sub_FOV1'][0,0]
coil_rec = coil_trace['rec_coil']
coilidx = np.asarray(list(np.ndindex(coil_rec.shape))[:-1])
coil_rec_ = np.array([coil_rec[idx[0],idx[1]][0] for idx in coilidx])
print(coil_rec_.shape)

coil_tra = coil_trace['tra_coil']
coilidx = np.asarray(list(np.ndindex(coil_tra.shape)))
coil_tra_ = [coil_tra[idx[0],idx[1]][0] for idx in coilidx]
for i in range(16):
    print(coil_tra_[i].shape)

