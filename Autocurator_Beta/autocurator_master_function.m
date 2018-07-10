% AUTOCURATOR_MASTER_FUNCTION(VID_DIR, T, CONTACTARRAY, JOBNAME) takes an input of a directory of
% your videos, a T array, and an empty contact array, and attempts to automatically curate them frame by frame using a
% convolutional neural network specified in MODEL
function [contacts] = autocurator_master_function(videoDir, tArray, contactArray, jobName)
  %% SETTINGS
  % Defaults
  % Bucket is Google Cloud storage location of data, url will begin with 'gs://'
  gcloudBucket = 'gs://whisker_training_data';
  % Project ID name
  gcloudProjectID = 'whisker-personal-autocurator';
  % Version number is for CloudML, 1.8 seems to work fine
  runVer = 1.8;
  % Model code gives location of python code that is actually uploaded to the cloud
  modCode = 'trainer.cnn_curator_cloud';
  % The location of your model code on the local drive
  modCodePath = 'trainer';
  % Path where the code you are currently running is
  autocuratorPath = 'C:\SuperUser\Documents\GitHub\whisker-autocurator';
  % Data center in which to process data. us-west1 (Oregon) is closest but
  % us-central1 (Iowa) is required to use TPUs and best GPUs
  region = 'us-east1';
  % Location of .yaml file used by Google Cloud for configuration settigns
  configFile = 'C:\Users\shires\AppData\Local\Google\Cloud_SDK\trainer\cloudml-gpu.yaml';
  % Model Path lists the location on the cloud where the training model is
  % stored including the model name
  modelPath = 'gs://whisker_training_data/Model_saves/rotated_21.h5';
  % Place to save uncurated datasets
  saveDir = 'C:\SuperUser\CNN_Projects\Phil_Pipeline\Datasets';
  % Place to save curated datasets
  newSaveDir = 'C:\SuperUser\CNN_Projects\Phil_Pipeline\Curated_Datasets';

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

  if exist('jobName') == false
    jobName = input('What would you like to call this training job? \n');
  end

  %Derived settings
  jobDir = [gcloudBucket '/Jobs'];
  dataBucket = [gcloudBucket '/Data'];
  cArray = load(contactArray);

  %% (2) Section for pre-processing images
  [contacts] = preprocess_pole_images('distance', T);

  %% (3) Turn directory into images
  % Take the videos supplied in the video directory and use them to create
  % batches of .png images that can be analyzed by the model
  
  system(['mkdir ' saveDir])
  contacts = videos_to_npy(contacts, videoDir, saveDir);

  %% (4) Move to cloud
  % Uploads pickle files to Google cloud
  npyDataPath = [saveDir '/*.npy'];
  gsutilUpCmd = sprintf('gsutil cp %s %s',...
                         npyDataPath, dataBucket);
  system(gsutilUpCmd)
  % Change project ID to avoid permission issues
  %changeProjCmd = ['gcloud set project

  %% (5a) Call Python code to use neural network and train on Google Cloud
  cd(autocuratorPath);
  cd Autocurator_Beta

  gcloudCmd = sprintf(['gcloud ml-engine jobs submit training %s ^'...
                        '--job-dir %s ^'...
                        '--runtime-version %.01f ^'...
                        '--module-name %s ^'...
                        '--package-path ./%s ^'...
                        '--region %s ^'...
                        '--config=%s ^'...
                        '-- ^'...
                        '--cloud_data_path %s '...
                        '--s_model_path %s '...
                        '--job_name %s '...
                        ], jobName, jobDir, runVer,...
                         modCode, modCodePath, region,...
                         configFile, dataBucket, modelPath,...
                         jobName);
  system(gcloudCmd)
  %pause(1800)

  %% (5b) Call Python code to use neural network and train on local computer
  % with a GPU (Lol, like we'll get a GPU)
  % {This section left unfinished until such time as the lab acquires
  % a GPU for neural network purposes}

  %% (6) Remove touch predictions from Google Cloud
  %gcloudBucket = 'gs://whisker_training_data';
  downloadName = ['/Data/*.pickle'];
  gsutilDownCmd = sprintf('gsutil cp %s%s %s',...
                         gcloudBucket, downloadName, newSaveDir);
  system(gsutilDownCmd)

  %% (7) Convert to contact array (or fill in contact array in reverse)
  %system(['py retrieve_npy_labels.py --data_dir ' newSaveDir]);
  % If error: uncomment the below:
  %[contacts] = preprocess_pole_images('distance', T);
  write_to_contact_array(newSaveDir, contacts, contactArray, jobName);

  %% (8) Finish 
  % Use to clear needed directories 
  clearDir = input('Do you want to clear data directories? [Y/N] ', 's');
  % Clearing section below
  if strcmpi(clearDir, 'Y')
      system(['del /q ' saveDir])
      system(['del /q ' newSaveDir])
      system(['gsutil rm -rf ' dataBucket])
  end

