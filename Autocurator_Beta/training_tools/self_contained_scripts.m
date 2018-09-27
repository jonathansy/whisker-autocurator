%% Intro:
% This is basically a section of scripts to run in order to run
% self-contained cloud commands easily without needing to adjust the entire
% autocurater script. It's currently optimized for uploading a training
% dataset and training a model. Each section can be run independently

%% Uploads pickle files to Google cloud

  npyDataPath = 'C:\SuperUser\CNN_Projects\Phil_Dataset\SavingDir/';
  dataBucket = 'gs://whisker_training_data/Data';
  gsutilUpCmd = sprintf('gsutil rm %s/*.pickle',...
                         dataBucket);
  system(gsutilUpCmd)

  %% Run cloud training
  % Variables:
  jobName = 'rotated_30';
  gcloudBucket = 'gs://whisker_training_data';
  gcloudProjectID = 'whisker-personal-autocurator';
  runVer = 1.8;
  modCode = 'trainer.train_cloud_model_numpy_2';
  modCodePath = 'trainer';
  region = 'us-east1';
  configFile = 'C:\Users\shires\AppData\Local\Google\Cloud_SDK\trainer\cloudml-gpu.yaml';
  modelPath = 'gs://whisker_training_data/Model_saves/';
  dataBucket = 'gs://whisker_training_data/Training_Data';
  autocuratorPath = 'C:\SuperUser\Documents\GitHub\whisker-autocurator';

  % Derived variables
  jobDir = [gcloudBucket '/Jobs'];
  modelName = ['model_' jobName '.h5'];

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
                         configFile, dataBucket, modelPath,...
                         jobName);
  system(gcloudCmd)

  %% Frame intensity
  averages = zeros(1,2000);
  for i = 1083:3084
      nFrameMat = edge(vA.frames(i).cdata(:,:,1));
      nFrameMat = nFrameMat((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
      aSide = mean(mean(nFrameMat(1:15,1:46)));
      bSide = mean(mean(nFrameMat(16:61,1:15)));
      cSide = mean(mean(nFrameMat(47:61,:)));
      dSide = mean(mean(nFrameMat(1:46,47:61)));
      averages(i-1082) = mean([aSide + dSide]);
      avg = averages(i-1082); 
      cFileName = sprintf('frame_%d.png', (i-1082));
      if avg > 0.02
          % Save as inFrame
          saveLocation = 'C:\SuperUser\CNN_Projects\Test_Run_1\inFrame';
          cFullFileName = [saveLocation filesep cFileName];
          imwrite(nFrameMat, cFullFileName, 'png');
      else
          % Save as outFrame
          saveLocation = 'C:\SuperUser\CNN_Projects\Test_Run_1\outFrame';
          cFullFileName = [saveLocation filesep cFileName];
          imwrite(nFrameMat, cFullFileName, 'png');
      end
  end
