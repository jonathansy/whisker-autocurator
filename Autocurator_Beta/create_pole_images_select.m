% CREATE_POLE_IMAGES(VIDEO_DIR, SAVE_DIR, SORT, VARARGIN) takes the videos in
% VIDEO_DIR and converts them to 61x61 pixel images centered around the pole.
% These images are then written to SAVE_DIR. This process requires ffmpeg to work

function create_pole_images_select(videoDir, saveDir, contacts, tArray)
  % Check directories and dependencies -----------------------------------------
  if exist(videoDir) ~= 7; error('Cannot find video directory'); end
  if exist(saveDir) ~= 7; error('Cannot find save directory'); end

  % Find ffmpeg
  ffPath = 'C:\SuperUser\Code\ffmpeg';
  if exist([ffPath '.exe']) ~= 2; error('Cannot find ffmpeg'); end

  % Check other input options and set defaults ---------------------------------
  % DEFAULTS
  runParallel = true; % Use parpool
  samplePoleImage = 'C:\SuperUser\Code\ML_whisker_image_dev\samplePoleMat'; % Picture of pole for correlation
  otherTempDir = false; % Whether to create a temp directory separate from image dir
  maxFrames = 3900;
  testFrameNumber = 1500;

  % Load sample image of pole for matrix correlation
  sPM = load(samplePoleImage);
  samplePoleMat = sPM.samplePoleMat;
  % Load contact array if applicable
  contactArray = contacts;

  %Parallel run options --------------------------------------------------------
  if runParallel == true
    delete(gcp('nocreate'))
    corenum = feature('numcores');
    corenum = corenum - 1;
    parpool(corenum);
  end

  % Make temp directory
    tempDir = [saveDir filesep 'Temp'];

  % Displacement calculator
  try % Choose 15 to avoid issues at start of trial
    spikeNum = tArray.trials{15}.spikesTrial.xsgFileNum;
    trialNum = tArray.trials{15}.trialNum;
    displacement = trialNum - spikeNum;
  catch
    warning('Unable to calculate displacement from trial array');
    displacement = input(['Please enter an integer value indicating the \n'...
                          'displacement between the video number and trial \n'...
                          'array index number \n']);
  end

  % Convert to images with ffmpeg and then process in loop ---------------------
  vList = dir([videoDir '/*.mp4']); % Get list of mp4s
  videoList = {vList(:).name};
  numVideos = length(videoList);
  tic;
  if runParallel == true
    %Parallel stuff
    parfor i = 1:numVideos

      nTempDir = [tempDir '_' num2str(i)];
      cVid = [videoDir filesep videoList{i}];
      process_video(cVid, nTempDir, ffPath,...
                    contacts, samplePoleMat, testFrameNumber,...
                    displacement, saveDir, contactArray);
    end
  else
    %Non-parallel stuff
    for i = 1:numVideos
      cVid = [videoDir filesep videoList{i}];
      process_video(cVid, tempDir, ffPath,...
                    contacts, samplePoleMat, testFrameNumber,...
                    displacement, saveDir, contactArray);
    end
  end
  h = toc
end % ==========================================================================

% Actual video processing occurs here
function process_video(videoName, tempLocation, ffPath,...
                       contactCell, samplePoleMat, tFrameNum,...
                       displacement, saveDir, cArray)
  % Section of preprocessing if we need to sort the videos ---------------------

  % Find number of video
  % Some regular expression stuff I never thought I'd use again:
  exprNum = '[0123456789]+.mp4';
  resultStr = regexp(videoName, exprNum, 'match'); %Should return #.mp4
  numStr = resultStr{1}(1:(end-4)); %Strip '.mp4' to leave just video number
  vidNumber = str2num(numStr);
  % Now check the contact array
  if isempty(cArray)
   error('No contact array provided to sort video')
  end
  % Calculate displacement between video number and trial index
  % Determined by xsg files in tArray in code above
  searchNum = vidNumber - displacement;



  % Check for video without contact array data ---------------------------------
  if searchNum < 1 || searchNum > length(cArray.contacts)
      return
  end
  if searchNum < length(cArray)
    % In this conditional, the array is empty and we cannot process this video
    % by sorting by touch. We will thus skip this video
    return
  else
    % Make touch array for sorting
    cTouchArray = cArray{searchNum};
  end

  % Make temp images -----------------------------------------------------------
  % Create directory for writing images
  system(['mkdir ' tempLocation]);
  % Create image filename for image stack
  [~,imFileName,~] = fileparts(videoName);
  % Use ffmpeg to convert video to tiff stack
  ffCmd = sprintf('%s -i %s -b:v 800k %s%s%s_',...
                   ffPath, videoName, tempLocation, filesep, imFileName);
  ffCmd = [ffCmd '%05d.png'];
  system(ffCmd);
  imList = dir([tempLocation '/*.png']);

  % Find pole location in this video -------------------------------------------
  testFrame = imread([tempLocation filesep imList(tFrameNum).name]);
  corrPoints = normxcorr2(samplePoleMat, testFrame(:,:,1));
  [yCorr, xCorr] = find(corrPoints==max(corrPoints(:)));
  xPole = xCorr - (size(samplePoleMat, 2) /2);
  yPole = yCorr - (size(samplePoleMat, 1) /2);
  poleBox = [yPole-30, yPole+30, xPole-30, xPole+30];

  % Read images into MATLAB and process ----------------------------------------
  for i = 1:length(imList)
    if ~exist(cTouchArray) || i > length(cTouchArray)
      imMat = imread([tempLocation filesep imList(i).name]);
      imMat = imMat(:,:,1);
      nFrameMat = imMat((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
      cFileName = imList(i).name;
  % Rewritten from touch-sort
          %Save frame in "NonTouches"
          cFullFileName = [saveDir filesep cFileName];
          imwrite(diffFrame, cFullFileName, 'png');
    else %Touch array exists
      imMat = imread([tempLocation filesep imList(i).name]);
      imMat = imMat(:,:,1);
      nFrameMat = imMat((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
      cFileName = imList(i).name;
      if cTouchArray(i) == -1
        %Save frame in "Touches"
        cFullFileName = [saveDir filesep cFileName];
        imwrite(diffFrame, cFullFileName, 'png');
      else %Delete image
        system(['del /f ' tempLocation])
      end
    end
    %
  end

  % Delete temp directory ------------------------------------------------------
  system(['rd /s /q ' tempLocation])

end
