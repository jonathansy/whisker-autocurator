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
# Job name is sued to name the output file
parser.add_argument('--job_name',
                    required=True,
                    help='Directory with saved images',
                    )
args = vars(parser.parse_args())
data_dir = format(args["data_dir"])
job_name = format(args["job_name"])

# Figure out where everything is
data_list = os.listdir(data_dir)

# Need to unpickle files
all_labels = []
for data_name in data_list:
    data_path = data_dir + '/' + data_name
    with open(pickle_name, 'rb') as pickle_file:
        num_array = pickle.load(pickle_file)

# Save numpy array
output_name =  
