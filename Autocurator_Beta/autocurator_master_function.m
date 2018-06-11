% AUTOCURATOR_MASTER_FUNCTION(VID_DIR, T, CONTACTARRAY, JOBNAME) takes an input of a directory of
% your videos, a T array, and an empty contact array, and attempts to automatically curate them frame by frame using a
% convolutional neural network specified in MODEL
function [contacts] = autocurator_master_function(videoDir, tArray, contactArray, jobName)
  %% SETTINGS
  % Defaults
  % Bucket is Google Cloud storage location of data, url will begin with 'gs://'
  gcloudBucket = 'gs://whisker_training_data';
  % Version number is for CloudML, 1.0 seems to work fine
  runVer = 1.0;
  % Model code gives location of python code that is actually uploaded to the cloud
  modCode = 'trainer.cnn_curator_cloud.py';
  % The location of your model code on the local drive
  modCodePath = 'C:\SuperUser\Trainer';
  % Data center in which to process data. us-west1 (Oregon) is closest but
  % us-central1 (Iowa) is required to use TPUs and best GPUs
  region = 'us-central1';
  % Location of .yaml file used by Google Cloud for configuration settigns
  configFile = 'C:\Users\shires\AppData\Local\Google\Cloud_SDK\trainer\cloudml-gpu.yaml';
  % max_batch is the maximum number of images to put in a single pickle dataset.
  % Larger amounts will require more RAM to create datasets as well as process
  % them on the cloud. RAM issue is solved by creating multiple datasets and
  % loading and processing them one at a time so that order is maintained
  max_batch = 20000;

  %% (1) Input checks and base variables
%   if exist(model) ~= 2
%     error(['Input for "MODEL" should be the full path of the h5 file \n'...
%     'containing the training model'])
  if exist(videoDir) ~= 7
    error('Cannot find the image directory specified')
  end
  if exist(contactArray) ~= 2
    error('Cannot find empty contact array, remember to supply full path!')
  end
  if exist(tArray) ~= 2
    error('Cannot find trial array, remember to supply full path!')
  else
      T = load(tArray);
      T = T.T;
  end

  if exist(jobName) == false
    jobName = input('What would you like to call this training job? \n');
  end

  %Derived settings
  jobDir = [gcloudBucket '/Jobs'];
  dataDir = [gcloudBucket '/Data'];
  cArray = load(contactArray);

  %% (2) Section for pre-processing images
  % pre_process_images(saveDir, cArray)
  [contacts] = preprocess_pole_images('distance', T);

  %% (3) Turn directory into images
  % Take the videos supplied in the video directory and use them to create
  % batches of .png images that can be analyzed by the model
  saveDir = [videoDir filesep 'pole_images'];
  system(['mkdir ' saveDir])
  create_pole_images_select(videoDir, saveDir, contacts);

  %% (4) Convert images to numpy arrays and move to cloud
  % Call Python code to convert the entire dataset of images into numpy arrays
  % that can be read by the Keras API (and Tensorflow)
  numpyCmd = sprintf('py images_to_numpy(%s,%s,%s)', saveDir, max_batch, jobName);
  system(numpyCmd)
  % Uploads pickle files to Google cloud
  npyDataPath = saveDir;
  gsutilUpCmd = sprintf('gsutil cp %s*.pickle %s',...
                         npyDataPath, dataBucket);
  system(gsutilUpCmd)


  %% (5a) Call Python code to use neural network and train on Google Cloud
  gcloudCmd = sprintf(['gcloud ml-engine jobs submit training %s ^'...
                        '--job-dir %s ^'...
                        '--runtime-version %.01f ^'...
                        '--module-name %s ^'...
                        '--package-path ./%s ^'...
                        '--region %s ^'...
                        '--config=%s ^'...
                        '-- ^'...
                        '--train-file %s'...
                        '--job_name %s'
                        ], jobName, jobDir, runVer,...
                         modCode, modCodePath, region,...
                         configFile, dataBucket, jobName);
  system(gcloudCmd)

  %% (5b) Call Python code to use neural network and train on local computer
  % with a GPU (Lol, like we'll get a GPU)
  % {This section left unfinished until such time as the lab acquires
  % a GPU for neural network purposes}

  %% (6) Remove touch predictions from Google Cloud
  downloadName = [jobName '_curated_labels.pickle'];
  gsutilDownCmd = sprintf('gsutil cp %s%s %s',...
                         gcloudBucket, downloadName, saveDir);
  system(gsutilDownCmd)

  %% (7) Convert to contact array (or fill in contact array in reverse)
  system(['py retrieve_npy_labels'])
  contactArray = write_to_contact_array(labels, contactArray);

  %% (8) Finish
  fprintf(['Finished autocuration. \n'...
           'Total time elapsed: %d hours, %d minutes %d seconds'], tHour, tMin, tSec)
