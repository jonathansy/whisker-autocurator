import sys
import os
import numpy as np
import pickle
import scipy.misc

target = 'AH0706x171106-217_dataset.npy'
path = 'C:/SuperUser/CNN_Projects/Test_Run_1/706_171106/NPYs/'
fullpath = path + target
X = np.load(fullpath)
print(X.shape)
a = X[1300,:,:]
scipy.misc.imsave('C:/SuperUser/CNN_Projects/Test_Run_1/706_171106/outfile1.jpg', a)
print(X[:,:,0])
X = np.reshape(X, [2870, 61, 61, 1],
               order='A')
print(X.shape)
b = X[1300,:,:,0]
scipy.misc.imsave('C:/SuperUser/CNN_Projects/Test_Run_1/706_171106/outfile2.jpg', b)
print(X[0,:,:,0])
# def load_image_data(data_path):
#     # Shape of images (temporarily hard-coded)
#     img_rows = 61
#     img_cols = 61
#     # Parses through data on cloud and unpickles it
#     # Import Data
#     with open(data_path, mode='rb') as pickle_file:
#         i_data = pickle.load(pickle_file)
#     i_data = np.array(i_data, dtype=np.uint8)
#     i_data = i_data.reshape(i_data.shape[0], img_rows, img_cols)
#     input_shape = (img_rows, img_cols, 1)
#     i_data = i_data.astype('float32')
#     i_data /= 255
#     return i_data
#
# X = load_image_data(fullpath)
# print(X.shape)

# a = np.array([[1,2,3],[4,5,6],[7,8,9]])
# b = np.array([[1,2,3],[4,5,6],[7,8,9]])
# c = np.array([a,b])
# c = c.reshape(3,3,2)
# print(c)
# print(c.shape)