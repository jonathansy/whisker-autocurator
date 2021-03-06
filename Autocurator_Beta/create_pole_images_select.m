% CREATE_POLE_IMAGES(VIDEO_DIR, SAVE_DIR, SORT, VARARGIN) takes the videos in
% VIDEO_DIR and converts them to 61x61 pixel images centered around the pole.
% These images are then written to SAVE_DIR. This process requires ffmpeg to work

function create_pole_images_select(videoDir, saveDir, contacts)
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

  %Parallel run options --------------------------------------------------------
  if runParallel == true
    delete(gcp('nocreate'))
    corenum = feature('numcores');
    corenum = corenum - 1;
    parpool(corenum);
  end

  % Displacement calculator
%   try % Choose 15 to avoid issues at start of trial
%     spikeNum = tArray.trials{15}.spikesTrial.xsgFileNum;
%     trialNum = tArray.trials{15}.trialNum;
%     displacement = trialNum - spikeNum;
%   catch
%     warning('Unable to calculate displacement from trial array');
%     displacement = input(['Please enter an integer value indicating the \n'...
%                           'displacement between the video number and trial \n'...
%                           'array index number \n']);
%   end

  % Convert to images with ffmpeg and then process in loop ----------------
  vList = dir([videoDir '/*.mp4']); % Get list of mp4s
  videoList = {vList(:).name};
  numVideos = length(videoList);
  tic;
  if runParallel == true
    %Parallel stuff
    parfor i = 1:length(contacts)
      tNum = contacts{i}.trialNum;
      cVid = [videoDir filesep videoList{i}];
      process_video(cVid, ffPath,...
                    samplePoleMat, testFrameNumber,...
                    saveDir, contacts);
    end
  else
    %Non-parallel stuff
    for i = 1:length(contacts)
      tNum = contacts{i}.trialNum;
      cVid = [videoDir filesep videoList{i}];
      process_video(cVid, ffPath,...
                    samplePoleMat, testFrameNumber,...
                    saveDir, contacts);
    end
  end
  h = toc
end % ==========================================================================

% Actual video processing occurs here
function process_video(videoName, ffPath,...
                       samplePoleMat, tFrameNum,...
                       saveDir, cArray)
  % Section of preprocessing for matching ---------------------------------

  % Find number of video
  % Some regular expression stuff I never thought I'd use again:
  exprNum = '[0123456789]+.mp4';
  resultStr = regexp(videoName, exprNum, 'match'); %Should return #.mp4
  numStr = resultStr{1}(1:(end-4)); %Strip '.mp4' to leave just video number
  vidNumber = str2num(numStr);
  % See if corresponding trial number exists
  tNum = [];
  for i = 1:length(cArray)
      if vidNumber == cArray{i}.trialNum
          tNum = i; 
      end 
  end
  
  if isempty(tNum) %No number found, skip video
      return
  else
      contactList = cArray{tNum}.labels;
  end

  % Make temp images ------------------------------------------------------
  % Create image filename for image stack
  [~,imFileName,~] = fileparts(videoName);
  
  % Create directory for writing temp images 
  tempLocation = [saveDir filesep imFileName '_Temp'];
  system(['mkdir ' tempLocation]);
  
  % Use ffmpeg to convert video to tiff stack
  ffCmd = sprintf('%s -i %s -b:v 800k %s%s%s_',...
                   ffPath, videoName, tempLocation, filesep, imFileName);
  ffCmd = [ffCmd '%05d.png'];
  system(ffCmd);
  imList = dir([tempLocation '/*.png']);
  
  % Create directory for final image save
  saveLocation = [saveDir filesep imFileName];
  system(['mkdir ' saveLocation]);

  % Find pole location in this video --------------------------------------
  testFrame = imread([tempLocation filesep imList(tFrameNum).name]);
  corrPoints = normxcorr2(samplePoleMat, testFrame(:,:,1));
  [yCorr, xCorr] = find(corrPoints==max(corrPoints(:)));
  xPole = xCorr - (size(samplePoleMat, 2) /2);
  yPole = yCorr - (size(samplePoleMat, 1) /2);
  poleBox = [yPole-30, yPole+30, xPole-30, xPole+30];

  % Read images into MATLAB and process -----------------------------------
  for i = 1:length(imList)
      % Check for unlabeled image, do not process
      if i > length(contactList)
          return
      end
      % Crop image and save if needed
      imMat = imread([tempLocation filesep imList(i).name]);
      imMat = imMat(:,:,1);
      nFrameMat = imMat((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
      cFileName = imList(i).name;
      if contactList(i) == 2
          %Save frame in processing directory 
          cFullFileName = [saveLocation filesep cFileName];
          imwrite(nFrameMat, cFullFileName, 'png');
      end %Otherwise leave image for deletion
      %
  end

  % Delete temp directory -------------------------------------------------
  system(['rd /s /q ' tempLocation])

end
