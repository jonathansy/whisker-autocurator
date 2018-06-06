# New python code for numpy array input, for local and GCP use
# Base imports
from __future__ import print_function
import numpy as np
import argparse
import h5py
import tensorflow as tf
import time
from PIL import Image
import pickle
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
# GCP imports
import logging
from tensorflow.python.lib.io import file_io
# Local imports
import sys
import os, os.path

# Reset graph in case of re-runs
tf.reset_default_graph()


def train_model(train_file='gs://whisker_training_data',
                job_dir='gs://whisker_training_data/Model_saves/Logs', **args):
    logging.info('Training directory is ' + train_file)
    # set base variables
    batch_size = 1024
    num_classes = 2
    epochs = 54

    # input image dimensions
    img_rows, img_cols = 61, 61

    # Import Data
    with file_io.FileIO((train_file + '/phil_diff_ds.pickle'), mode='rb') as pickle_file:
        x_train = pickle.load(pickle_file)
    x_train = np.array(x_train, dtype=np.uint8)
    with file_io.FileIO((train_file + '/phil_diff_labels.pickle'), mode='rb') as pickle_file:
        y_train = pickle.load(pickle_file)
    y_train = np.array(y_train, dtype=np.uint8)
    # with file_io.FileIO((train_file + '/phil_rpp2_ds.pickle'), mode='rb') as pickle_file:
    #     x_train2 = pickle.load(pickle_file)
    # x_train2 = np.array(x_train2, dtype=np.uint8)
    # with file_io.FileIO((train_file + '/phil_rpp2_labels.pickle'), mode='rb') as pickle_file:
    #     y_train2 = pickle.load(pickle_file)
    # y_train2 = np.array(y_train2, dtype=np.uint8)
    with file_io.FileIO((train_file + '/valid_diff_ds.pickle'), mode='rb') as pickle_file:
        x_test = pickle.load(pickle_file)
    x_test = np.array(x_test, dtype=np.uint8)
    with file_io.FileIO((train_file + '/valid_diff_labels.pickle'), mode='rb') as pickle_file:
        y_test = pickle.load(pickle_file)
    y_test = np.array(y_test, dtype=np.uint8)

    logging.info('Loaded files')
    # Sanity checks
    # print(len(x_train))
    # print(x_train[0])

    if K.image_data_format() == 'channels_first':
        x_train = x_train.reshape(x_train.shape[0], 1, img_rows, img_cols)
        # x_train2 = x_train2.reshape(x_train2.shape[0], 1, img_rows, img_cols)
        x_test = x_test.reshape(x_test.shape[0], 1, img_rows, img_cols)
        input_shape = (1, img_rows, img_cols)
    else:
        x_train = x_train.reshape(x_train.shape[0], img_rows, img_cols, 1)
        # x_train2 = x_train2.reshape(x_train2.shape[0], img_rows, img_cols, 1)
        x_test = x_test.reshape(x_test.shape[0], img_rows, img_cols, 1)
        input_shape = (img_rows, img_cols, 1)

    x_train = x_train.astype('float32')
    # x_train2 = x_train2.astype('float32')
    x_test = x_test.astype('float32')
    x_train /= 255
    # x_train2 /= 255
    x_test /= 255
    # logging.info('x_train shape:', x_train.shape)
    # logging.info(x_train.shape[0], 'train samples')
    # logging.info(y_train.shape[0], 'test samples')

    # convert class vectors to binary class matrices
    y_train = keras.utils.to_categorical(y_train, num_classes)
    # y_train2 = keras.utils.to_categorical(y_train2, num_classes)
    y_test = keras.utils.to_categorical(y_test, num_classes)

    # Callbacks
    # board_log = TensorBoard(log_dir=job_dir,
    #                         histogram_freq=0,
    #                         batch_size=1024,
    #                         write_graph=True,
    #                         write_grads=False,
    #                         write_images=True,
    #                         embeddings_freq=0,
    #                         embeddings_layer_names=None,
    #                         embeddings_metadata=None)

    # Setup model
    logging.info('Setting up model')
    model = Sequential()

    model.add(Conv2D(32, kernel_size=(3, 3),
                     activation='relu',
                     input_shape=input_shape))
    model.add(Conv2D(64, (6, 6), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    model.add(Flatten())
    model.add(Dense(128, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(num_classes, activation='softmax'))

    # model.add(Conv2D(32, (3, 3), padding='same',
    #              input_shape=x_train.shape[1:]))
    # model.add(Activation('relu'))
    # model.add(Conv2D(32, (3, 3)))
    # model.add(Activation('relu'))
    # model.add(MaxPooling2D(pool_size=(2, 2)))
    # model.add(Dropout(0.25))
    #
    # model.add(Conv2D(64, (3, 3), padding='same'))
    # model.add(Activation('relu'))
    # model.add(Conv2D(64, (3, 3)))
    # model.add(Activation('relu'))
    # model.add(MaxPooling2D(pool_size=(2, 2)))
    # model.add(Dropout(0.25))
    #
    # model.add(Flatten())
    # model.add(Dense(512))
    # model.add(Activation('relu'))
    # model.add(Dropout(0.5))
    # model.add(Dense(num_classes))
    # model.add(Activation('softmax'))

    model.compile(loss=keras.losses.categorical_crossentropy,
                  metrics=['accuracy'],
                  optimizer=keras.optimizers.Adam())

    model.fit(x_train, y_train,
              batch_size=batch_size,
              epochs=40,
              verbose=1,
              shuffle=True,
              validation_data=(x_test, y_test))
    # Now fit to new data
    # model.fit(x_train2, y_train2,
    #           batch_size=batch_size,
    #           epochs=5,
    #           verbose=1,
    #           shuffle=True,
    #           validation_data=(x_test, y_test))
    # model.fit(x_train, y_train,
    #           batch_size=batch_size,
    #           epochs=5,
    #           verbose=1,
    #           shuffle=True,
    #           validation_data=(x_test, y_test))
    # model.fit(x_train2, y_train2,
    #           batch_size=batch_size,
    #           epochs=5,
    #           verbose=1,
    #           shuffle=True,
    #           validation_data=(x_test, y_test))
    # model.fit(x_train, y_train,
    #           batch_size=batch_size,
    #           epochs=5,
    #           verbose=1,
    #           shuffle=True,
    #           validation_data=(x_test, y_test))
    # model.fit(x_train2, y_train2,
    #           batch_size=batch_size,
    #           epochs=5,
    #           verbose=1,
    #           shuffle=True,
    #           validation_data=(x_test, y_test))
    # Final evaluation
    score = model.evaluate(x_test, y_test, verbose=0)
    logging.info('Test loss:', score[0])
    logging.info('Test accuracy:', score[1])


    # Saving section
    # if job_dir.startswith("gs://"):
    #     model.save('autocurator_modelm.h5')
    #     copy_file_to_gcs(job_dir, 'autocurator_modelm.h5')
    # else:
    #     model.save(os.path.join(job_dir, 'autocurator_model.h5'))

    # Section to evaluate incorrect things
    predictions = model.predict(x_test, verbose=0, steps=None)
    # logging.info(len(predictions))
    # logging.info(len(y_test))
    # nons = predictions != y_test
    # logging.info(len(nons))
    # incorrects = np.nonzero(nons.reshape(-1))
    # logging.info(len(incorrects))
    # incorrect_set = x_test[incorrects]
    # logging.info(len(incorrect_set))
    # Re-pickle incorrect images
    with file_io.FileIO(os.path.join(job_dir, 'predictions.pickle'), mode='wb') as handle:
        pickle.dump(predictions, handle)



def copy_file_to_gcs(job_dir, file_path):
    with file_io.FileIO(file_path, mode='rb') as input_f:
        with file_io.FileIO(os.path.join(job_dir, file_path), mode='w+') as output_f:
            output_f.write(input_f.read())


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--train-file',
        help='GCS or local paths to training data',
        required=True
    )

    parser.add_argument(
        '--job-dir',
        help='GCS location to write checkpoints and export models',
        required=True
    )
    args = parser.parse_args()
    arguments = args.__dict__
    job_dir = arguments.pop('job_dir')

    train_model(**arguments)
    #train_model('C:\SuperUser\Code\ML_whisker_image_dev')
