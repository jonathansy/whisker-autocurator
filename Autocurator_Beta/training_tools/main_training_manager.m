% Top level MATLAB script to generate a new model based on contact array
% training data.
% Create 2018-09-28 by J. Sy, derived from legacy scripts
jobName = 'Proto_14';

%% Section 1: Setting inputs
% List and location of contact arrays with touch/no-touch labels
contactArrayDir = 'Z:\Users\Jonathan_Sy\JK_Pipeline\Unfininshed_ConTA';
contArrayList = {'ConTA_JK025pre_(session_8)',...
                 'ConTA_AH0688_170821_PM0150_AAAA'};

% List and location of trial arrays: each trial array must be
% placed in the same order on the list as its corresponding contact array
trialArrayDir = 'Z:\Users\Jonathan_Sy\JK_Pipeline\tArrays';
trialArrayList = {'JK025pre1_T',...
                  'trial_array_25'};

if length(contArrayList) ~= length(trialArrayList)
  error('Each contact array must have a matching trial array!')
end

% Location of video files: leave videoArrayList empty if the
% exact path can be determined from mouse and session name found in the trial
% array
videoDir = 'Y:\Whiskernas\JK\whisker\tracked\JK025pre1';
videoList = {};

% Training settings
sizeROI = 81; % length/width of training image in pixels

% Cloud settings: determine different training factors. See Google Cloud
% documentation or read-me for more details
upload = true;
autocuratorPath = 'C:\SuperUser\Documents\GitHub\whisker-autocurator';
trainCodePath = 'C:\SuperUser\Documents\GitHub\whisker-autocurator\Autocurator_Beta\training_tools';
gcloudBucket = 'gs://whisker_training_data';
gcloudProjectID = 'whisker-personal-autocurator';
runVer = 1.8;
modCode = 'trainer.train_model_from_tfrecords';
modCodePath = 'trainer';
region = 'us-central1';
configFile = 'C:\Users\shires\AppData\Local\Google\Cloud_SDK\trainer\cloudml-gpu.yaml';
dataBucket = [gcloudBucket '/Data'];
jobDir = [gcloudBucket '/Jobs'];
modelName = [jobName '.h5'];
exportPath = 'gs://whisker_training_data/Model_saves';

% Transfer directory: the location where numpy arrays will be stored before
% being transfered to the cloud
transferDir = 'C:\SuperUser\CNN_Projects\Model_v2\Transfer';

% Optional: supply list of contact arrays with relevant points indicated
useSubsetOfData = false; % Set to 'true' and the trainer will only use images
% and labels marked as touches in this second set of contact arrays. In the
% second set, a touch label is not actually meant to indicate a touch, but merely
% that the point should be curated. The first set of contact arrays will still
% be used for training labels.
if useSubsetOfData == true
  subContactArrayDir = 'C:\SuperUser\CNN_Projects\Model_v2\ConTA';
  subContArrayList = {};
end

%% Section 2: Loop through contact array and create dataset
for i = 1:length(contArrayList)
  contactArrayFullPath = [contactArrayDir filesep contArrayList{i}];
  trialArrayFullPath = [trialArrayDir filesep trialArrayList{i}];
  cArray = load(contactArrayFullPath);
  cArray = cArray.contacts;
  tArray = load(trialArrayFullPath);
  %tArray = tArray.T;
  tArray = tArray.arrayT
  % Find full video path
  if isempty(videoList)
    %mouse = tArray.mouseName;
    %session = tArray.sessionName;
    %vidPath = [videoDir filesep mouse filesep session];
    vidPath = videoDir;
  end
  % Now call function to turn contact arrays into training, test, valid sets
  create_training_data_images(tArray, cArray, sizeROI, vidPath, transferDir, i)
end
% Turn numpy datasets into tf.dataset format and concatenate together
dataCmd = ['py ' trainCodePath filesep 'create_main_dataset.py'];
system(dataCmd)

%% Section 3: Upload dataset
% (3a) Uploads pickle files to Google cloud
% npyDataPath = [transferDir '/*.tfrecords'];
% if upload == true
%     gsutilUpCmd = sprintf('gsutil -m cp %s %s',...
%         npyDataPath, dataBucket);
%     system(gsutilUpCmd)
% end
% Change project ID to avoid permission issues
%changeProjCmd = ['gcloud set project

%% Section 4: Call Python code to train neural network and train on Google Cloud
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
                      '--data_path %s '...
                      '--export_path %s '...
                      '--model_name %s '...
                      ], jobName, jobDir, runVer,...
                       modCode, modCodePath, region,...
                       configFile, dataBucket, exportPath,...
                       modelName);
system(gcloudCmd)
