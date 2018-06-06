import numpy as np
import pickle
import os


def import_and_read_ds(file_location):
    # Unpickle and look at info
    with open(file_location, 'rb') as pickle_file:
        predictions = pickle.load(pickle_file)

    return predictions


if __name__ == '__main__':
    # Set default directory here:
    pred_path = 'C:\SuperUser\CNN_Projects\predictions.pickle'
    test_path = 'C:\SuperUser\Code\ML_whisker_image_dev\phil_rpp_labels.pickle'
    im_path = 'C:\SuperUser\Code\ML_whisker_image_dev\phil_rpp_ds.pickle'
    new_pred = import_and_read_ds(pred_path)
    actual_y = import_and_read_ds(test_path)

    # Now we can run some comparisons
    print(len(new_pred), ' predictions')
    print(len(actual_y), ' actual test points')
    # Loop and turn predictions to classes
    predictions = np.zeros(len(new_pred))
    print(predictions.shape, ' preall')
    for i in range(0,29999):
        if new_pred[i][0] >= new_pred[i][1]:
            predictions[i] = 0
        else:
            predictions[i] = 1
    nons = np.array(predictions) != np.array(actual_y)
    print(nons[0])
    print(nons.shape)
    incorrects = np.nonzero(nons)
    print(incorrects[0].shape)
    image_list = import_and_read_ds(im_path)
    image_list = np.array(image_list)
    print(len(image_list), 'is image')
    wrong_images = image_list[incorrects[0]]
    image_list = []
    print(wrong_images.shape)
    print(wrong_images[0,:,:])
