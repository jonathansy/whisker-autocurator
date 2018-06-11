# Load basic modules
import sys
import glob
import os, os.path
import numpy as np
import argparse
import h5py
import time
from PIL import Image
import pickle
# Load tensorflow-related modules
import tensorflow as tf
from tensorflow.python.lib.io import file_io
# Keras
import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras.layers import Activation, Dropout, Flatten, Dense
from keras.models import load_model
from keras.preprocessing.image import ImageDataGenerator
from keras import callbacks
from keras.callbacks import ProgbarLogger
from keras.callbacks import TensorBoard
from keras import backend as K

# =============================================================

# NOTE: we may require a version to automatically load and curate by batch if
# an entire session's dataset doesn't fit into RAM

# Reset graph in case of re-runs
tf.reset_default_graph()


def load_image_data(data_path):
    # Parses through data on cloud and unpickles it
    # Import Data
    with file_io.FileIO((data_path), mode='rb') as pickle_file:
        i_data = pickle.load(pickle_file)
    i_data = np.array(x_train, dtype=np.uint8)
    return i_data


def curate_data_with_model(data, model_path):
    # Begin by loading our pre-curated model
    curation_model = load_model(model_path)
    # Actual prediction step occurs here
    curated_array = curation_model.predict(data,
                                         batch_size=batch_size,
                                         verbose=0,
                                         steps=None)
    return curated_labels


def write_array_to_file(curated_labels, file_name):
    file_name = file_name + '_curated_labels_.pickle'
    # Re-pickle our numpy array and write to path
    with file_io.FileIO(file_name), mode='wb') as handle:
        pickle.dump(curated_array, handle)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # Model path
    parser.add_argument('s_model_path',
                        help='Full path including file name of desired cnn model',
                        required=True
                        )
    # Data path
    parser.add_argument('cloud_data_path',
                        help='Full path including file name of NP dataset',
                        required=True
                        )
    # What to call labels
    parser.add_argument('job_name',
                        help='Used to name label file after job',
                        required=True
                        )
    # Run main functions
    datasets = file_io.get_matching_files('*.pickle')
    numData = len(datasets)
    total_c_labels = []
    for num in range(0, numData):
        current_dataset = job_name + '_image_dataset_' + num + '.pickle'
        data_path = cloud_data_path + current_dataset
        im_data = load_image_data(data_path)
        c_labels = curate_data_with_model(im_data, s_model_path)
        total_c_labels = c_labels.append(c_labels)
    # Write total label set to file
    write_array_to_file(total_c_labels, job_name)
