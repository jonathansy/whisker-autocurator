%CREATE_TRAINING_DATASET(VIDEODIR, CONTACTARRAY, SAVEDIR) will take a video input (VIDEODIR),
%a contract array input (CONTACTARRAY) and separate the videos into "touch" and
%"non-touch" classes within SAVEDIR. If SAVEDIR has already been created, the
%new images will be sorted into the pre-existing directories. This is designed so
%CREATE_TRAINING_DATASET can be iterated to build a larger sample dataset. It is
%designed to be used in a convolutional neural network to classify images.
%CREATE_TRAINING_DATASET(VIDEODIR, CONTACTARRAY, SAVEDIR, SKIPT) can be used
%to skip trials by providing their indices to SKIPT

% Change-log
% >>>
% Editor              Change                        Date
%----------------------------------------------------------------------------
% J. Sy               Created function              2017-01-29

function create_training_dataset(videoDir, contactArray, saveDir, skipT)
  % SETUP SECTION --------------------------------------------------------------
  %Make base directory if it doesn't exist
  if exist(saveDir) ~= 7
    mkdir saveDir;
    mkdir [saveDir filesep 'Touches'];
    mkdir [saveDir filesep 'NonTouches'];
  end
  % Make touches dir if it doesn't exist
  if exist([saveDir filesep 'Touches']) ~= 7
    mkdir [saveDir filesep 'Touches'];
  end
  % Make nontouches dir if it doesn't exist
  if exist([saveDir filesep 'NonTouches']) ~= 7
    mkdir [saveDir filesep 'NonTouches'];
  end

  %Set mp4 name list
  vList = dir([videoDir '/*.mp4']);
  videoList = {vList(:).name};
  numVideos = length(videoList);

  %load contact array as cArray
  cArray = load(contactArray);
  numTrials = length(cArray.contacts);

  %Check skipT
  if nargin == 3
    skipT = [];
  end

  %SECTION TO CROP TO AREA AROUND POLE -----------------------------------------
  %Find sample image of area around pole to extract
  if exist('samplePoleMat.mat') == 2
    sPMat = load('samplePoleMat.mat');
    samplePoleMat = sPMat.samplePoleMat;
  else
    sampleImgMat = find_pole_info(videoList{1}.name, 'auto');
  end

  % LOOP THROUGH VIDEOS --------------------------------------------------------
  % Designed to run in parallel
%   delete(gcp('nocreate'))
%   corenum = feature('numcores');
%   parpool(corenum)
%   p = gcp('nocreate');
%   addAttachedFiles(p, 'loop_through_trials');
  %Main loop
  parfor i = 1:numTrials
    loop_through_trials(i, skipT, videoList, cArray, samplePoleMat, saveDir)
  end

  %Terminate main function
end

%===============================================================================
function [poleWindow] = find_pole_window(interestVid,poleMatrix)
  sampleFrameN = 80; %Should be where you know pole is visible
  sampleFTime = sampleFrameN; %Unfortunately these numbers don't match real time 
  %at the correct frame rate
  %Find pole location in this video
  %Note: pole location should not change on a frame by frame basis
  sampleV = VideoReader(interestVid);
  sampleV.CurrentTime = sampleFTime;
  sampleFrame = readFrame(sampleV);
  sampleFrame = sampleFrame(:,:,1);
  %Find correlation
  corrPoints = normxcorr2(poleMatrix, sampleFrame);
  [yCorr, xCorr] = find(corrPoints==max(corrPoints(:)));
  xPole = xCorr - (size(poleMatrix,2)/2);
  yPole = yCorr - (size(poleMatrix,1)/2);
  poleWindow = [yPole-30,yPole+30, xPole-30,xPole+30];
end

%===============================================================================
function loop_through_trials(iteration, skipT, videoList, cArray, poleMat, saveDir)
  if ~ismember(iteration+1,skipT) & ~isempty(cArray.contacts{iteration})
    vidIdx = [];
    trialNum = iteration + 2;
    trialStr = num2str(trialNum);
    searchStr = ['-' trialStr '.mp4'];
    idxGroup = strfind(videoList, searchStr);
    vidIdx = find(not(cellfun('isempty', idxGroup)));
    %Check to see if video exists
    if isempty(vidIdx)
      %Stuff
      fprintf('No video for trial %d, skipping \n', trialNum)
    else
      cVidName = videoList{vidIdx};
      %Extract pole area
      poleBox = find_pole_window(cVidName, poleMat);
      %LOOP THROUGH FRAMES
      cTouchArray = cArray.contacts{iteration}.contactInds{1};
      v = VideoReader(cVidName);
      v.CurrentTime = 0;
      for j = 1:3900
        %Video-reader stuff
        uncutFrame = readFrame(v);
        frameMatrix = uncutFrame(poleBox(1):poleBox(2),poleBox(3):poleBox(4));
        %Write current file name
        [~,vNameOnly,~] = fileparts(cVidName)
        cFileName = sprintf('%s_%04d.png',vNameOnly,j);
        if ismember(j,cTouchArray)
          %Save frame in "Touches"
          cFullFileName = [saveDir filesep 'Touches' filesep cFileName]
          imwrite(frameMatrix, cFullFileName, 'png');
        else
          %Save frame in "NonTouches"
          cFullFileName = [saveDir filesep 'NonTouches' filesep cFileName]
          imwrite(frameMatrix, cFullFileName, 'png');
        end %End of saving conditional
      end %End of inner for loop
    end %End of conditional for bypassing missing videos
  end %End of if statement for SKIP
end %End of function
