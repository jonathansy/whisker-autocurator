import os
import pickle
import numpy as np
from scipy import misc


def create_tf_ds(data_dir):
    # Package images from a directory into numpy array with labels
    # Set final variables
    labels = []
    new_ds = []

    # Write touches to list and alternate
    touch_dir = data_dir + '\Touches'
    t_file_list = os.listdir(touch_dir)
    non_touch_dir = data_dir + '/NonTouches'
    n_file_list = os.listdir(non_touch_dir)

    for t_image, n_image in zip(t_file_list, n_file_list):
        path_t = touch_dir + '/' + t_image
        path_n = non_touch_dir + '/' + n_image
        t_array = misc.imread(path_t)
        n_array = misc.imread(path_n)
        new_ds.append(t_array)
        new_ds.append(n_array)
        labels.append(0)
        labels.append(1)
        if len(new_ds) > 199999:
            break

    print(len(new_ds))

    return new_ds, labels


if __name__ == '__main__':
    # Set base data directory
    base_dir = 'C:\SuperUser\Code\ML_whisker_image_dev\Touch_Dataset_Upsampled'
    # Create three datasets for each type of dataset
    [train_ds, train_labels] = create_tf_ds(base_dir + '\Train_Edge')
    [valid_ds, valid_labels] = create_tf_ds(base_dir + '/Validate_Edge')
    # [test_ds, test_labels] = create_tf_ds(base_dir + '/Test')

    # Do the pickling
    with open('e_train_ds.pickle', 'wb') as handle:
        pickle.dump(train_ds, handle)
    # with open('valid_ds.pickle', 'wb') as handle:
    #     pickle.dump(valid_ds, handle)
    with open('e_valid_ds.pickle', 'wb') as handle:
        pickle.dump(valid_ds, handle)

    with open('e_train_labels.pickle', 'wb') as handle:
        pickle.dump(train_labels, handle)
    # with open('valid_labels.pickle', 'wb') as handle:
    #     pickle.dump(valid_labels, handle)
    with open('e_valid_labels.pickle', 'wb') as handle:
        pickle.dump(valid_labels, handle)
