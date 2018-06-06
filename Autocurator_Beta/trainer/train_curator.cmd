:: Script for running Google Cloud job submission
@ECHO OFF
set BUCKET_NAME=whisker_training_data
set JOB_NAME=Model_Saves
set JOB_DIR=gs://whisker_training_data/Model_Saves
set REGION=us-west1

ECHO ON

gcloud ml-engine jobs submit training %JOB_NAME% ^
  --job-dir %JOB_DIR% ^
  --runtime-version 1.0 ^
  --module-name trainer.whisker_touch_cnn_gcp ^
  --package-path ./trainer ^
  --region %REGION% ^
  --config=trainer/cloudml-gpu.yaml ^
  -- ^
  --train-file gs://whisker_training_data

  ::End of code
