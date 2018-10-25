import os
import sys
import numpy as np
import tensorflow as tf
import argparse
from os.path import basename

# This script is designed to take a directory full of numpy datasets and
# create a single dataset formated in the tf.dataset format for training on
# the cloud

def main(np_location, data_name):
    np_list = os.listdir(np_location)
    first_train = 1
    first_valid = 1
    for np_file in np_list:
        np_array = np.load(np_file)
        np_fname = basename(np_file)
        if np_fname[6:9] == 'Data':
            label_name = np_fname[0:4] + '_Labels' + np_fname[10:]
            np_labels = np.load(label_name)
        iter_dataset = tf.data.Dataset.from_tensor_slices((np_array, np_labels))
        # Check if training or validation set and assign accordingly 
        if np_fname[0:4] == 'Train'
            if first_train == 1:
                main_dataset = iter_dataset
                first_train = 0
            else:
                main_dataset = tf.concatenate(main_dataset, iter_dataset)
        elif np_fname[0:4] == 'Valid'
            if first_valid == 1:
                main_dataset = iter_dataset
                first_valid = 0
            else:
                main_dataset = tf.concatenate(main_dataset, iter_dataset)


# Handle inputs
if __name__ == '__main__':
    # Argument section
    parser = argparse.ArgumentParser()
    # Directory location of numpy dataset files
    parser.add_argument('--numpy_file_path',
                        help='Full path to numpy datasets and labels',
                        required=True
                        )
    # Name to use for final datasets
    parser.add_argument('--name_dataset',
                        help='Full path to place to put models',
                        required=True
                        )
    args = vars(parser.parse_args())
    numpy_file_path = format(args["numpy_file_path"])
    name_dataset = format(args["name_dataset"])

    main(numpy_file_path, name_dataset)
