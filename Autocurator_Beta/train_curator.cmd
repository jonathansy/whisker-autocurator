:: Script for running Google Cloud job submission
@ECHO OFF
set BUCKET_NAME=whisker_training_data
set JOB_NAME=Job_103
set JOB_DIR=gs://whisker_training_data/Model_Saves/Logs
set REGION=us-central1

ECHO ON

gcloud ml-engine jobs submit training %JOB_NAME% ^
  --job-dir %JOB_DIR% ^
  --runtime-version 1.6 ^
  --module-name trainer.whisker_touch_cnn_np ^
  --package-path C:\Users\shires\AppData\Local\Google\Cloud_SDK\trainer ^
  --region %REGION% ^
  --config=C:\Users\shires\AppData\Local\Google\Cloud_SDK\trainer\cloudml-gpu.yaml ^
  -- ^
  --train-file gs://whisker_training_data

  ::End of code
