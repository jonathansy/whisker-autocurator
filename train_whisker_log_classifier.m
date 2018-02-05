%TRAIN_WHISKER_LOG_CLASSIFIER(INPUTDIRECTORY,CARRAY) trains a logistic classifer
%based on pre-curated contact arrays or retrains and adjusts the classifer based
%on inputs from low confidence curation.
%INPUTDIRECTORY must be the directory where the trial's mp4 files are located
%CARRAY must be the contact array corresponding to those mp4 files.
%TRAIN_WHISKER_LOG_CLASSIFIER(INPUTDIRECTORY,CARRAY,'multi-session') will use more
%than one session to train data. In this case, INPUT DIRECTORY and CARRAY must be
%cell arrays containing names of mp4 directories and contact arrays with the order
%matching.
%TRAIN_WHISKER_LOG_CLASSIFIER(INPUTDIRECTORY,CARRAY,'trainwithmat') allows inputing
%a pre-wrapped touch array for CARRAY instead of the whole contact array
%TRAIN_WHISKER_LOG_CLASSIFIER(INPUTDIRECTORY,CARRAY,'enhance',LOWCONRESULTS) will
%retrain the classifier based on human input to the trials the classifier is least
%confident on.

%===============================================================================
% CHANGE LOG
% Name            Edit                     Date
%-----------------------------------------------------------------------
% J. Sy           Created initial code     2018-01-17
% Begin main function ==========================================================
function [classifier] = train_whisker_log_classifier(inputDirectory,cArray,varargin)
  % SET DEFAULT ARGUMENTS ------------------------------------------------------
  sessionType = 'single-session';
  trainingType = 'first-pass';
  unpackCArray = true;
  vidType = '.mp4';

  % SELECT FEATURES ------------------------------------------------------------
  % It's really too painful to make the features selectable as function arguments
  % instead, please select them here by commenting/uncommenting
  %First-pass features (Can be derived directly from image)
  feature.pixelsAroundPole = [];
  feature.houghLineDistance = [];
  feature.houghLineVelocity = [];
  feature.pixelDiff = [];
  %Second-pass Features (require an initial touch array prediction)
  feature.touchesAround = [];

  % INPUT SECTION --------------------------------------------------------------
  if nargin > 2
    switch varargin{1}
    case 'prewrapped_data'
      unpackCArray = false;
    case 'multi-session'
      sessionType = 'multi-session';
    case 'enhance'
      trainingType = 'retrain'
      varargin{2} = lowConResults;
    otherwise
      error('Invalid input argument')
    end
  end

  % UNPACK DATA ----------------------------------------------------------------
  if strcmp(sessionType,'single-session')
    %Create touch array
     if unpackCArray == 1
       touchInfo = extract_touch_array(cArray);
     else
       touchInfo.touchArray{1} = cArray;
     end
     %Unpack mp4s
   end

 end % End of main function ====================================================

 % ACCESSORY FUNCTIONS =========================================================
 function touchInfo = extract_touch_array(conInput)
   %Load Array
   location = exist(conInput);
   switch location
   case 0
     error('Cannot find contact array')
   case 1
     %Pre-loaded contact array
     cData{1} = conInput;
   case 2
     %Load contact array
     cData{1} = load(conInput);
   case 7
     matFiles = dir([conInput filesep '*.mat'])
     if length(matFiles) > 1
       for i = 1:length(matFiles)
         if contains(matFiles(i).name,'ConTA','IgnoreCase',true)
           cData{i} = load([conInput filesep matFiles(i).name]);
         end
       end
     else
       cData{1} = load([conInput filesep matFiles.name]);
     end
   otherwise
     error('Your input is wrong')
   end
   %This loop is only needed if multiple contact arrays
   numSessions = length(cData);
   touchInfo.array = cell(numSessions,1);
   touchInfo.missingTrials = cell(numSessions,1)
   for i = 1:numSessions
     nTrials = numel(cData{i}.contacts);
     touchArray = zeros(4000,1)
     touchArray = repmat(touchIdx,nTrials,1)
     mTrials = [];
     for i = 1:nTrials
       if ~isempty(cData{i}.contacts{j})
         tempCIdx = cData{i}.contacts{j}.contactInds{1};
         tempCIdx = tempCIdx + 4000*(j-1);
         touchArray(tempCIdx,1) = 1;
       else
         mTrials = [mTrials j];
       end
     end
     touchInfo.array{i} = touchArray;
     touchInfo.missingTrials{i} = mTrials;
   end
 end
