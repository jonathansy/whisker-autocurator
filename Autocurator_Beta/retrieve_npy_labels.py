import os
import sys
import numpy as np
import pickle
import argparse

# Directory input
parser = argparse.ArgumentParser()
# Data path
parser.add_argument('--data_dir',
                    required=True,
                    help='Directory with saved images',
                    )
args = vars(parser.parse_args())
data_dir = format(args["data_dir"])

# Figure out where everything is
data_list = os.listdir(data_dir)

# Main loop
all_labels = []
for data_name in data_list:
    data_path = data_dir + '/' + data_name
    # Need to unpickle files
    with open(data_path, 'rb') as pickle_file:
        num_array = pickle.load(pickle_file)
    # Save numpy array
    output_name =  data_dir + '/' + data_name[:-7] + '_labels.npy'
    print(output_name)
    np.save(output_name, num_array)
