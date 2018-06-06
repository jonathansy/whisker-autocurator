import os
import pickle
import numpy as np
from scipy import misc


def create_tf_ds(data_dir):
    # Package images from a directory into numpy array with labels
    # Set final variables
    t_labels = []
    t_ds = []
    v_ds = []
    v_labels = []

    # Write touches to list and alternate
    touch_dir = data_dir + '\Touches'
    t_file_list = os.listdir(touch_dir)
    non_touch_dir = data_dir + '/NonTouches'
    n_file_list = os.listdir(non_touch_dir)

    # Write touches to file (non-mixed dataset only appropriate for validation)
    for t_image in t_file_list:
        path_t = touch_dir + '/' + t_image
        t_array = misc.imread(path_t)
        t_ds.append(t_array)
        t_labels.append(0)
        if len(t_ds) > 29999:
            v_ds.append(t_array)
            v_labels.append(0)
            if len(v_ds) > 9999:
                break
    # Write NonTouches to file
    for n_image in n_file_list:
        path_n = non_touch_dir + '/' + n_image
        n_array = misc.imread(path_n)
        t_ds.append(n_array)
        t_labels.append(1)
        if len(t_ds) > 39999:
            v_ds.append(t_array)
            v_labels.append(1)
            if len(v_labels) > 14999:
                break

    print(len(t_ds))
    print(len(v_ds))
    return t_ds, t_labels, v_ds, v_labels


if __name__ == '__main__':
    # Set base data directory
    base_dir = 'C:\SuperUser\CNN_Projects\ImageSet_01_Diff'
    # Create three datasets for each type of dataset
    [train_ds, train_labels, valid_ds, valid_labels] = create_tf_ds(base_dir)
    # [valid_ds, valid_labels] = create_tf_ds(base_dir + '/Validate_Edge')
    # [test_ds, test_labels] = create_tf_ds(base_dir + '/Test')

    # Do the pickling
    with open('phil_diff_ds.pickle', 'wb') as handle:
        pickle.dump(train_ds, handle)
    with open('valid_diff_ds.pickle', 'wb') as handle:
        pickle.dump(valid_ds, handle)
    # with open('phil_valid_ds.pickle', 'wb') as handle:
    #     pickle.dump(valid_ds, handle)

    with open('phil_diff_labels.pickle', 'wb') as handle:
        pickle.dump(train_labels, handle)
    with open('valid_diff_labels.pickle', 'wb') as handle:
        pickle.dump(valid_labels, handle)
    # with open('u_valid_labels.pickle', 'wb') as handle:
    #     pickle.dump(valid_labels, handle)
