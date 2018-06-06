#!/bin/bash
echo "Submiting training job to Google Cloud"
echo "================================================="

export BUCKET_NAME=whisker_training_data
export JOB_NAME="Model_Saves"
export JOB_DIR=gs://$BUCKET_NAME/$JOB_NAME
export REGION=us-west1-b

gcloud ml-engine jobs submit training $JOB_NAME \
  --job-dir $JOB_DIR \
  --runtime-version 1.0 \
  --module-name trainer.whisker_touch_cnn_gcp \
  --package-path ./trainer \
  --region $REGION \
  --config=trainer/cloudml-gpu.yaml \
  -- \
  --train-file gs://whisker_training_data

echo "Finished training"
echo "================================================="
