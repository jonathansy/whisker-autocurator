import os
import dill
import tensorflow as tf


def create_tf_ds(data_dir):
    # Package images from a directory into numpy array with labels
    # Set final variables
    labels = []
    image_list = []

    # Write touches to list
    touch_dir = data_dir + '\Touches'
    file_list = os.listdir(touch_dir)
    num_labels = len(file_list)
    image_list = image_list + file_list
    new_labels = [0] * num_labels
    labels = labels + new_labels

    # Write nontouches to list
    non_touch_dir = data_dir + '/NonTouches'
    file_list = os.listdir(non_touch_dir)
    num_labels = len(file_list)
    image_list = image_list + file_list
    new_labels = [0] * num_labels
    labels = labels + new_labels

    # Create TF dataset
    print(len(image_list))
    new_ds = tf.data.Dataset.from_tensor_slices((image_list, labels))
    print(new_ds.output_types)
    print(new_ds.output_shapes)
    return new_ds


def _parse_function(filename, label):
    image_string = tf.read_file(filename)
    image_decoded = tf.image.decode_image(image_string)
    image_resized = tf.image.resize_images(image_decoded, [60, 60])
    return image_resized, label


if __name__ == '__main__':
    # Set base data directory
    base_dir = 'C:\SuperUser\Code\ML_whisker_image_dev\Touch_Dataset_Alpha'
    # Create three datasets for each type of dataset
    train_ds = create_tf_ds(base_dir + '\Train')
    train_ds = train_ds.map(_parse_function)
    # valid_ds = create_tf_ds(base_dir + '/Validate')
    # test_ds = create_tf_ds(base_dir + '/Test')

    # Do the pickling
    # with open('train_ds.pickle', 'wb') as handle:
    #     dill.dump(train_ds, handle)
    # with open('valid_ds.pickle', 'wb') as handle:
    #     dill.dump(valid_ds, handle)
    # with open('test_ds.pickle', 'wb') as handle:
    #     dill.dump(test_ds, handle)
