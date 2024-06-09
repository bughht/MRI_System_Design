import numpy as np
import matplotlib.pyplot as plt
from pydicom import read_file
import cv2 as cv
import os

# Load dicom files
def load_scan(path):
    slices = [read_file(path + '/' + s) for s in os.listdir(path)]
    slices.sort(key = lambda x: float(x.ImagePositionPatient[2]))
    try:
        slice_thickness = np.abs(slices[0].ImagePositionPatient[2] - slices[1].ImagePositionPatient[2])
    except:
        slice_thickness = np.abs(slices[0].SliceLocation - slices[1].SliceLocation)

    for s in slices:
        s.SliceThickness = slice_thickness

    return slices

# Generate brain mask
def generate_brain_msk(img):
    msk = img>300
    for i,slice in enumerate(msk):
        slice = cv.erode(slice.astype(np.uint8), np.ones((3,7), np.uint8), iterations=3)
        ret, markers = cv.connectedComponents(slice)
        marker_area = [np.sum(markers==m) for m in range(np.max(markers)) if m!=0] 
        largest_component = np.argmax(marker_area)+1
        slice = (markers==largest_component)
        slice = cv.dilate(slice.astype(np.uint8), np.ones((2,4), np.uint8), iterations=3)
        msk_bck = np.zeros((slice.shape[0]-2,slice.shape[1]-2), np.uint8)
        cv.floodFill(msk_bck, slice, (0,0), 255)
        slice = np.zeros_like(slice)
        slice[1:-1,1:-1] = cv.bitwise_not(msk_bck)
        msk[i] = slice!=0
    return msk

if __name__ == "__main__":
    dcm_noshim = load_scan('data\gre_fieldmap_1.0mm_no_shim_B0Map_203')
    dcm_shim = load_scan('data\gre_fieldmap_1.0mm_shim_B0Map_303')
    echo1 = load_scan('data\gre_fieldmap_1.0mm_no_shim_Echo1_201')

    B0_noshim = np.stack([s.pixel_array for s in dcm_noshim])
    B0_shim = np.stack([s.pixel_array for s in dcm_shim])
    data_echo1 = np.stack([s.pixel_array for s in echo1])

    msk = generate_brain_msk(data_echo1)

    B0_noshim*=msk
    B0_shim*=msk
    
    phase_msk_noshim = B0_noshim*np.pi/4096
    phase_msk_shim = B0_shim*np.pi/4096


    plt.subplot(1,2,1)
    plt.imshow(phase_msk_noshim[2], cmap='jet')
    plt.colorbar()
    plt.subplot(1,2,2)
    plt.imshow(phase_msk_shim[2], cmap='jet')
    plt.colorbar()
    plt.show()