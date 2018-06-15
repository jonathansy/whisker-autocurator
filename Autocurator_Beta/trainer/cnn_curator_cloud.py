# Load basic modules
import sys
import glob
import os, os.path
import numpy as np
import argparse
import h5py
import time
import logging
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
    # Shape of images (temporarily hard-coded)
    img_rows = 61
    img_cols = 61
    # Parses through data on cloud and unpickles it
    # Import Data
    with file_io.FileIO(data_path, mode='rb') as pickle_file:
        i_data = pickle.load(pickle_file)
    i_data = np.array(i_data, dtype=np.uint8)
    i_data = i_data.reshape(i_data.shape[0], img_rows, img_cols, 1)
    input_shape = (img_rows, img_cols, 1)
    i_data = i_data.astype('float32')
    i_data /= 255
    return i_data


def load_model_from_gcs(model_path):
    model_file = file_io.FileIO(model_path, mode = 'rb')
    temp_model_location = './temp_model.h5'
    temp_model_file = open(temp_model_location, 'wb')
    temp_model_file.write(model_file.read())
    temp_model_file.close()
    model_file.close()
    model = load_model(temp_model_location)
    return model


def curate_data_with_model(data, curation_model):
    # Actual prediction step occurs here
    curated_labels = curation_model.predict(data,
                                         batch_size=1024,
                                         verbose=0,
                                         steps=None)
    return curated_labels


def write_array_to_file(curated_labels, file_name, iter):
    iter = str(iter)
    file_name = file_name + '_curated_' + iter + '.pickle'
    # Re-pickle our numpy array and write to path
    with file_io.FileIO(os.path.join('gs://whisker_training_data/Curated_Data', file_name),
                        mode='wb') as handle:
        pickle.dump(curated_labels, handle)


if __name__ == '__main__':

    # Argument section
    parser = argparse.ArgumentParser()
    # Model path
    parser.add_argument('--s_model_path',
                        help='Full path including file name of desired cnn model',
                        required=True
                        )
    # Data path
    parser.add_argument('--cloud_data_path',
                        help='Full path including file name of NP dataset',
                        required=True
                        )
    # What to call labels
    parser.add_argument('--job_name',
                        help='Used to name label file after job',
                        required=True
                        )
    # Stuff for compatibility
    parser.add_argument('--job-dir',
                        help='GCS location to write checkpoints and export models',
                        required=True
                        )
    args = vars(parser.parse_args())
    s_model_path = format(args["s_model_path"])
    job_name = format(args["job_name"])
    cloud_data_path = format(args["cloud_data_path"])

    # Run main functions
    search_Loc = cloud_data_path + '/*.pickle'
    datasets = file_io.get_matching_files(search_Loc)
    numData = len(datasets)
    logging.info(numData)

    # Load model
    cur_model = load_model_from_gcs(s_model_path)

    # Loop
    logging.info('Starting the loop')
    num = 0
    for d_set in datasets:
        logging.info(d_set)
        data_path = d_set
        im_data = load_image_data(data_path)
        c_labels = curate_data_with_model(im_data, cur_model)
        write_array_to_file(c_labels, job_name, num)
        num = num + 1
    # Write total label set to file

