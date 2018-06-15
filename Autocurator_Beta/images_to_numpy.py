import os
import sys
import pickle
import numpy as np
from scipy import misc
import argparse

# Default variables
# max_batch_size = 20000


def images_to_array(save_dir, job_name):
    # Convert images to numpy array
    trial_dir_list = os.listdir(save_dir)
    # Make directory to put datasets into
    data_dir = save_dir + '/' + job_name + '_datasets'
    os.mkdir(data_dir)

    for imdir in trial_dir_list:
        image_list = os.listdir(save_dir + '/' + imdir)
        # Write to array
        current_ds = []
        pickle_name = data_dir + '/' + imdir + '_image_dataset.pickle'
        for image in image_list:
            path_im = save_dir + '/' + imdir + '/' + image
            im_array = misc.imread(path_im)
            current_ds.append(im_array)
        with open(pickle_name, 'wb') as handle:
            pickle.dump(current_ds, handle)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # Image path
    parser.add_argument('--save_dir',
                        required=True,
                        help='Directory with saved images',
                        )
    # Name of job (for dataset naming purposes)
    parser.add_argument('--job_name',
                        required=True,
                        help='Name of this Cloud ML job',
                        )
    args = vars(parser.parse_args())
    save_dir = format(args["save_dir"])
    job_name = format(args["job_name"])
    # Call main function
    images_to_array(save_dir, job_name)
