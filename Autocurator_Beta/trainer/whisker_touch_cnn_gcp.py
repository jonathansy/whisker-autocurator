# A version of of the whisker curation convolutional neural network project
# featuring Keras as our high-level API atop tensorflow.

#Change-log >>>
#   Date            Change                      Editor
#---------------------------------------------------------------------------
#   2018-02-07      Initial creation            J. Sy
#   2018-03-12      Google Cloud compatibility  J. Sy

# Load modules
from __future__ import print_function
import numpy as np
import argparse
import h5py
import tensorflow as tf
import logging
import time
from IPython.display import display
from PIL import Image
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
from tensorflow.python.lib.io import file_io
import sys
import os, os.path

tf.reset_default_graph()

# Main function ================================================================
def train_model(train_file='gs://whisker_training_data',
                job_dir='whisker_training_data/Model_saves',**args):

    logging.info('Starting main function')
    #Setup basic options
    batch_size = 1024
    num_classes = 2 #Touch and NonTouch
    epochs = 50
    nb_train_samples = 619800
    nb_validation_samples = 167600
    training_dir = train_file + '/Train'
    logging.info('Training directory is ' + training_dir)
    validation_dir = train_file + '/Validate/Validate'
    test_dir = train_file + '/Test'
    #Set log directory
    # tb_logs = callbacks.TensorBoard(
    #         log_dir=job_dir + '/Logs',
    #         histogram_freq=0,
    #         write_graph=True,
    #         embeddings_freq=0)

    #Dimensions of our 60x60 image
    img_rows, img_cols = 61, 61

    #Format input image
    if K.image_data_format() == 'channels_first':
        input_shape = (3, img_cols, img_rows)
    else:
        input_shape = (img_cols, img_rows, 3)

    #Setup callbacks
    prog_log = ProgbarLogger(count_mode='samples',
                            stateful_metrics=None)
    board_log = TensorBoard(log_dir=job_dir,
                            histogram_freq=0,
                            batch_size=1024,
                            write_graph=True,
                            write_grads=False,
                            write_images=False,
                            embeddings_freq=0,
                            embeddings_layer_names=None,
                            embeddings_metadata=None)

    #Model is setup here =======================================================
    # Train using sequential model
    model = Sequential()
    # We use rectified linear units ('relu')
    model.add(Conv2D(32, kernel_size=(3, 3),
                     activation='relu',
                     input_shape=input_shape))
    model.add(Conv2D(64, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    model.add(Flatten())
    model.add(Dense(128, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(num_classes, activation='softmax'))

    model.compile(loss=keras.losses.categorical_crossentropy,
                  optimizer=keras.optimizers.Adadelta(),
                  metrics=['accuracy'])
    #===========================================================================

    #Form training, validation, and test datasets
    logging.info('Loading datasets from:')
    logging.info(training_dir)
    #Existence check
    logging.info(file_io.file_exists('C:\SuperUser\Code\ML_whisker_image_dev\Touch_Dataset_Alpha\Test\Touches'))
    logging.info(os.path.exists('C:\SuperUser\Code\ML_whisker_image_dev\Touch_Dataset_Alpha\Test\Touches'))

    train_ds = ImageDataGenerator(rescale=1. / 255).flow_from_directory(training_dir,
                                                    target_size =(61, 61),
                                                    classes =['Touches','NonTouches'],
                                                    batch_size =batch_size)
    valid_ds = ImageDataGenerator(rescale=1. / 255).flow_from_directory(validation_dir,
                                                    target_size =(61, 61),
                                                    classes =['Touches','NonTouches'],
                                                    batch_size =batch_size)
    test_ds = ImageDataGenerator(rescale=1. / 255).flow_from_directory(test_dir,
                                                    target_size =(61, 61),
                                                    classes =['Touches','NonTouches'],
                                                    batch_size =batch_size)
    logging.info('Finished loading datasets')

    #Network is actually trained in this step >>>
    train_steps = nb_train_samples // batch_size
    validate_steps = nb_validation_samples // batch_size
    logging.info('Training model')
    model.fit_generator(
              train_ds,
              steps_per_epoch=train_steps,
              epochs=epochs,
              verbose=1,
              validation_data=valid_ds,
              validation_steps=validate_steps,
              callbacks=[prog_log, board_log]
)
    score = model.evaluate_generator(
                test_ds,
                steps=None,
                max_queue_size=10,
                workers=1,
                use_multiprocessing=False)

    loggind.info('Test loss:', score[0])
    loggind.info('Test accuracy:', score[1])

    #Save the model we've now spent all our hard work training
    save_path = 'whisker_training_data/Model_Saves'
    model.save(save_path)
#End function ==================================================================

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
    #job_dir = arguments.pop('job_dir')

    train_model(**arguments)
