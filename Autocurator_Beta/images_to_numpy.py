import os
import pickle
import numpy as np
from scipy import misc

# Default variables
# max_batch_size = 20000

def images_to_array(save_dir, job_name, max_batch_size, start, batch_num):
    # Convert images to numpy array
    current_ds = []
    pickle_name = job_name + '_image_dataset_' + str(batch_num) + '.pickle'
    file_list = os.listdir(save_dir)
    total_images = len(file_list)
    check_end = start

    # Write to array
    for current_image in range(start, max_batch_size):
        image = file_list[current_image]
        path_im = save_dir + '/' + image
        im_array = misc.imread(path_im)
        current_ds.append(im_array)
        check_end = check_end + 1
        if check_end == total_images:
            break

    # Check if we have reached the end of the dataset
    if check_end == total_images:
        # Write dataset here
        with open(pickle_name, 'wb') as handle:
            pickle.dump(current_ds, handle)
        return
    else:
        # Also write dataset here
        with open(pickle_name, 'wb') as handle:
            pickle.dump(current_ds, handle)
        # Advance start spot for recursive bit
        start = start + max_batch_size
        batch_num = batch_num + 1
        images_to_array(save_dir, job_name, max_batch_size, start, batch_num)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # Image path
    parser.add_argument('save_dir',
                        help='Directory with saved images',
                        required=True
                        )
    # Batch size
    parser.add_argument('max_batch_size',
                        help='Number of images to put in a single batch',
                        required=True
                        )
    # Name of job (for dataset naming purposes)
    parser.add_argument('job_name',
                        help='Name of this Cloud ML job',
                        required=True
                        )
    # Call main function
    images_to_array(save_dir, job_name, match_batch_size, 0, 0)
