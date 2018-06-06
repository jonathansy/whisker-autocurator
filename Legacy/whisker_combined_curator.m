%WHISKER_COMBINED_CURATOR(OPTIONS, VARARGIN) takes a directory of processed mp4s and
%performs basic touch classification using a logistic classifier on mp4 frames.
% It returns results in the form [CLASSIFIER, TOUCHARRAY, CONFIDENCEARRAY, LOWCONFRAMES].
%OPTIONS is a string specifying how you want to use this classifier.
%WHISKER_COMBINED_CURATOR('autocurate', INPUTDIRECTORY, CLASSIFIER) is used for
%performing the initial classification and will return a touch array and confidence
%array that can be used later on in human-assisted curation. CLASSIFIER in
%this case must be a pre-developed classifier.
%WHISKER_COMBINED_CURATOR('train', INPUTDIRECTORY, TRAININGCONTACTARRAY) is used
%to train a new classifier based on pre-curated data. INPUTDIRECTORY must contain
%the training data video to be used. TRAININGCONTACTARRAY must be the array itself
%or a directory containing the array.
%WHISKER_COMBINED_CURATOR('trainwithmat', INPUTDIRECTORY, TRAININGCONTACTARRAY)
%functions like 'train' but TDATA is a matrix of touch vectors sorted by trial.
%WHISKER_COMBINED_CURATOR('retrain', INPUTDIRECTORY, TRAININGMAT,LOWCONRESULTS)
%will take the curated least confident data and attempt to make a better classifier.
%WHISKER_COMBINED_CURATOR('perfeval', INPUTDIRECTORY, TRAININGCONTACTARRAY, CLASSIFIER)
%will test the classifier on a test data set, INPUTDIRECTORY should contain the
%training video files. The output CONFIDENCEARRAY will now be the performance data.

%===============================================================================
% CHANGE LOG
% Name            Edit                        Date
%-----------------------------------------------------------------------
% J. Sy           Created control code        2018-01-10
% J. Sy           Created autocurator         2018-01-11
% J. Sy           Functions to unpack mp4s    2018-01-12
% J. Sy           Created log classifier      2018-01-17

%Begin command function ========================================================

function [classifier, touchArray, confidenceArray, lowConFrames] = whisker_combined_curator(options, varargin)
  switch options
  case 'autocurate'
    %Note: you need to have already trained a classifier to use this code
    inputDirectory = varargin{1};
    classifier = varargin{2}; %The CLASSIFIER output will show what you input for argument 2, this
    %might be redundant but it should remind you of what you used
    outputType = varargin{3}; %Used to adjust output, will either be touch array or contact array
    %poleDetectOption = varargin{4};
    [touchArray, confidenceArray, lowConFrames] = whisker_mp4_autocurator(classifier, inputDirectory, outputType);
  case 'train'
    %This option as well as 'trainwithmat' will generate a new classifier, which will output as a .mat file
    %You should use 'retrain' to adjust a pre-existing classifier.
    inputDirectory = varargin{1};
    trainingContactArray = varargin{2};
    classifier = train_whisker_log_classifier(inputDirectory, trainingContactArray);
  case 'trainwithmat'
    inputDirectory = varargin{1};
    trainingMat = varargin{2};
    classifier = train_whisker_log_classifier(inputDirectory, trainingMat, 'prewrapped_data');
  case 'retrain'
    %To adjust a pre-existing classifier which will be re-outputted as a .mat file.
    %You will need to feed the new classifier back into 'autocurate' to get the newest low-confidence
    %frames.
    inputDirectory = varargin{1};
    trainingMat = varargin{2};
    lowConResults = varargin{3};
    classifier = train_whisker_log_classifier(inputDirectory, trainingMat, 'enhance',lowConResults);
  case 'perfeval'
    %Should output a structure array with overall accuracy as well as number of
    %false positives and false negatives
    inputDirectory = varargin{1};
    trainingContactArray = varargin{2};
    classifier = varargin{3};
    touchArray = whisker_mp4_autocurator(classifier, inputDirectory,'evalmode');
    logClassAccuracy = evaluate_whisker_log_classifier(touchArray, trainingContactArray);
    %Note that the confidenceArray output is overwritten with stats and lowConFrames is ignored
    confidenceArray = logClassAccuracy;
  otherwise
    error('Invalid option')
  end
end
