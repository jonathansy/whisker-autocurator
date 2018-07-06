% VIDEOS_to_NPY_TRAINING(VIDEODIR, CONTACTARRAY) is a new and faster method
% of creating training datasets from image directories. Third argument SAVEDIR
% is optional if you want to save in someplace other than video directory
function videos_to_npy_training(videoDir, contactArray, saveDir)

  % Check existance
  if exist(videoDir) ~= 7
    error('Cannot find video directory')
  elseif exist(contactArray) ~= 2
    error('Cannot find saving directory')
  end
  samplePoleImage = 'C:\SuperUser\Code\ML_whisker_image_dev\samplePoleMat';

  % Load contact array
  c = load(contactArray);
  contacts = c.contacts;
  params = c.params;
  trialSet = params;

  % Establish number of trials in contacts and number of videos
  numTrials = length(contacts);
  vList = dir([videoDir '/*.mp4']); % Get list of mp4s
  videoList = {vList(:).name};
  numVideos = length(videoList);

  % Begin loop
  for i = 1:numTrials
    % Find indices of frames we need to curate
    try
        labels = contacts{i}.contactInds{1};
    catch
        continue
    end
    % Skip trial if no touches
    if isempty(labels)
      continue
    end

    % Find corresponding video
    trialNum = params.trialNums(i);
    for j = 1:numVideos
      videoName = videoList{j};
      exprNum = '[0123456789]+.mp4';
      resultStr = regexp(videoName, exprNum, 'match'); %Should return #.mp4
      numStr = resultStr{1}(1:(end-4)); %Strip '.mp4' to leave just video number
      vidNumber = str2num(numStr);
      if vidNumber == trialNum
        fullVidName = [videoDir filesep videoName];
        break
      else
        continue
      end
    end

    % If for some reason no video, skip
    if isempty(fullVidName)
      continue
    end

    % Load with mmread
    videoArray = mmread(fullVidName);

    % Find pole location in video
    sPM = load(samplePoleImage); % Saved picture of pole
    samplePoleMat = sPM.samplePoleMat;
    testFrame = videoArray.frames(1500).cdata(:,:,1);
    corrPoints = normxcorr2(samplePoleMat, testFrame(:,:,1));
    [yCorr, xCorr] = find(corrPoints==max(corrPoints(:)));
    xPole = xCorr - (size(samplePoleMat, 2) /2);
    yPole = yCorr - (size(samplePoleMat, 1) /2);
    % poleBox = [yPole-30, yPole+30, xPole-30, xPole+30];

    % Prep loop
    numRelFrames = 3000;
    finalMat = zeros(numRelFrames,61);
    finalMat = repmat(finalMat, 1,1,61);
    newLabels = zeros(1, numRelFrames);

    % Frame loop
    for k = 1:numRelFrames
      % Save label
      curIdx = k + 500;
      if ismember(curIdx, contacts{i}.contactInds{1})
        newLabels(k) = 1; % Mark as touch
        % --Repeated in both sections -------------------------------------
        curFrame = videoArray.frames(curIdx).cdata(:,:,1);
        % Create frame of zeros in order to mark pole position
        zeroFrame = zeros(size(testFrame));
        zeroFrame(yPole:yPole+1,xPole:xPole+1) = 1;
        % Create random rotation to stop model from over-generalizing
        rotAngle = randi(365,1);
        curFrame = imrotate(curFrame, rotAngle);
        zeroFrame = imrotate(zeroFrame, rotAngle);
        [newX, newY] = find(zeroFrame == 1);
        newX = ceil(mean(newX));
        newY = ceil(mean(newY));
        poleBox = [newX-30, newX+30, newY-30, newY+30];
        nFrameMat = curFrame((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
        nFrameMat = imadjust(nFrameMat);
        % Save Frame
        finalMat(k,:,:) = nFrameMat;
%         saveName = videoName(1:end-4);
%         cFullFileName = [saveDir filesep saveName '_' num2str(k) '.png'];
        % -----------------------------------------------------------------
        %imwrite(nFrameMat, cFullFileName, 'png');
      elseif sum(ismember([curIdx-5:curIdx+5], contacts{i}.contactInds{1})) > 0
        newLabels(k) = 0; % Mark as touch
        % --Repeated in both sections -------------------------------------
        curFrame = videoArray.frames(curIdx).cdata(:,:,1);
        % Create frame of zeros in order to mark pole position
        zeroFrame = zeros(size(testFrame));
        zeroFrame(yPole:yPole+1,xPole:xPole+1) = 1;
        % Create random rotation to stop model from over-generalizing
        rotAngle = randi(365,1);
        curFrame = imrotate(curFrame, rotAngle);
        zeroFrame = imrotate(zeroFrame, rotAngle);
        [newX, newY] = find(zeroFrame == 1);
        newX = ceil(mean(newX));
        newY = ceil(mean(newY));
        poleBox = [newX-30, newX+30, newY-30, newY+30];
        nFrameMat = curFrame((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
        nFrameMat = imadjust(nFrameMat);
        % Save Frame
        finalMat(k,:,:) = nFrameMat;
%         saveName = videoName(1:end-4);
%         cFullFileName = [saveDir filesep saveName '_' num2str(k) '.png'];
        % -----------------------------------------------------------------
        %imwrite(nFrameMat, cFullFileName, 'png');
      else
        newLabels(k) = -1; % Mark as unneeded
      end
    end
    % Trim unneeded frames
    noNeedIdx = find(newLabels == -1);
    newLabels(noNeedIdx) = [];
    finalMat(noNeedIdx,:,:) = [];


    % Save as npy file
    saveVidName = videoName(1:end-4);
    saveName = [saveDir filesep saveVidName '_dataset.npy'];
    writeNPY(finalMat, saveName)
    labelName = [saveDir filesep saveVidName '_labels.npy'];
    writeNPY(newLabels, labelName)

    % Clear variables
    videoArray = [];
    finalMat = [];
    fullVidName = [];
  end
