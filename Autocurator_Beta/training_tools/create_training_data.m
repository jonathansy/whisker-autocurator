% CREATE_TRAINING_DATA(TARRAY, CARRAY, SIZEROI, TRANSFERDIR) creates numpy
% datasets in TRANSFERDIR using training data based on labels in CARRAY and
% images of size SIZEROI located in VIDPATH.
function create_training_data(tArray, cArray, sizeROI, vidPath, transferDir, metaIter)
  bitSize = 8;
  maxRamGB = 1;
  % Derived variables
  framesPerSet = round(maxRamGB*(1024^3))/(2*bitSize*sizeROI*sizeROI);
  numTrials = length(cArray);
  roiRadius = round((sizeROI-1)/2);

  % Prep trial loop
  mainIter = 1;
  trainSetIter = 1;
  testSetIter = 1;
  validSetIter = 1;
  maxDataset = [];
  maxLabels = [];

  for i = 1:numTrials
    % Find indices of frames we need to curate
    try
        labels = cArray{i}.contactInds{1};
    catch
        continue
    end
    % Skip trial if no touches
    if isempty(labels)
      continue
    end
    % Find name of corresponding video, skip if no name
    try
      videoName = tArray.trials{i}.whiskerTrial.trackerFileName;
    catch
      continue
    end
    % Check full video path, skip if video doesn't exist
    fullVideoPath = [vidPath filesep videoName '.mp4'];
    if ~exist(fullVideoPath)
      continue
    end

    % Load with mmread
    videoArray = mmread(fullVideoPath);

    % Prep loop
    poleStartTime = round(1000*tArray.trials{i}.pinDescentOnsetTime);
    poleStopTime = round(1000*tArray.trials{i}.pinAscentOnsetTime);
    % Make sure pole stop time doesn't exceed video or bars
    if poleStopTime > length(videoArray.frames)
        poleStopTime = length(videoArray.frames);
    end
    if poleStopTime > length(tArray.trials{i}.whiskerTrial.barPos)
        poleStopTime = length(tArray.trials{i}.whiskerTrial.barPos);
    end
    numFrames = poleStopTime - poleStartTime;
    finalMat = zeros(numFrames,sizeROI);
    finalMat = repmat(finalMat, 1, 1, sizeROI);
    newLabels = zeros(1, numFrames);

    for j = poleStartTime:poleStopTime
      % Determine pole position
      xPole = tArray.trials{i}.whiskerTrial.barPos(j,2);
      yPole = tArray.trials{i}.whiskerTrial.barPos(j,3);
      
      % Check touch or no touch and write labels
      if ismember(j, cArray{i}.contactInds{1})
        newLabels(j) = 1; % Mark as touch
        % --Repeated in both sections -------------------------------------
        curFrame = videoArray.frames(j).cdata(:,:,1);
        % Create frame of zeros in order to mark pole position
        zeroFrame = zeros(size(curFrame));
        zeroFrame(yPole:yPole+1,xPole:xPole+1) = 1;
        % Create random rotation to stop model from over-generalizing
        rotAngle = randi(365,1);
        curFrame = imrotate(curFrame, rotAngle);
        zeroFrame = imrotate(zeroFrame, rotAngle);
        [newX, newY] = find(zeroFrame == 1);
        newX = ceil(mean(newX));
        newY = ceil(mean(newY));
        poleBox = [newX-roiRadius, newX + roiRadius, newY - roiRadius, newY + roiRadius];
        % Check if ROI exceeds edge of image and skip if so
        nFrameMat = curFrame((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
        nFrameMat = imadjust(nFrameMat);
        % Save Frame
        finalMat(j,:,:) = nFrameMat;
      
      % If non-touch, only write if close to actual touch 
      elseif sum(ismember([j-20:j+20], cArray{i}.contactInds{1})) > 0
        newLabels(j) = 0; % Mark as touch
        % --Repeated in both sections -------------------------------------
        curFrame = videoArray.frames(j).cdata(:,:,1);
        % Create frame of zeros in order to mark pole position
        zeroFrame = zeros(size(curFrame));
        zeroFrame(yPole:yPole+1,xPole:xPole+1) = 1;
        % Create random rotation to stop model from over-generalizing
        rotAngle = randi(365,1);
        curFrame = imrotate(curFrame, rotAngle);
        zeroFrame = imrotate(zeroFrame, rotAngle);
        [newX, newY] = find(zeroFrame == 1);
        newX = ceil(mean(newX));
        newY = ceil(mean(newY));
        poleBox = [newX-roiRadius, newX + roiRadius, newY - roiRadius, newY + roiRadius];
         % Check if ROI exceeds edge of image and shift as needed
        [yDim, xDim] = size(curFrame);
        if poleBox(1) < 1
            poleBox(2) = poleBox(2) + (1 - poleBox(1));
            poleBox(1) = 1;
        end
        if poleBox(2) > yDim
            poleBox(1) = poleBox(1) - (poleBox(2)-yDim);
            poleBox(2) = yDim;
        end
        if poleBox(3) < 1
            poleBox(4) = poleBox(4) + (1 - poleBox(3));
            poleBox(3) = 1;
        end
        if poleBox(4) > xDim
            poleBox(3) = poleBox(3) - (poleBox(4)-yDim);
            poleBox(4) = yDim;
        end
        nFrameMat = curFrame((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
        nFrameMat = imadjust(nFrameMat);
        % Save Frame
        finalMat(j,:,:) = nFrameMat;
        % Stuff
      end
    end

    maxDataset = cat(1, maxDataset, finalMat);
    maxLabels = [maxLabels newLabels];
    if length(maxLabels) > framesPerSet && rem(mainIter,4) ~= 0
      % Save as training data
      saveVidName = ['Train_Data_' num2str(trainSetIter) '_Session_' num2str(metaIter) '.npy'];
      saveName = [transferDir filesep saveVidName];
      writeNPY(maxDataset, saveName)
      labelName = ['Train_Labels_' num2str(trainSetIter) '_Session_' num2str(metaIter) '.npy'];
      saveLabelName = [transferDir filesep labelName];
      writeNPY(maxLabels, saveLabelName)
      trainSetIter = trainSetIter + 1;
      mainIter = mainIter + 1;
      maxDataset = [];
      maxLabels = [];
    elseif length(maxLabels) > framesPerSet && rem(mainIter,4) == 0
      % Save as validation data
      saveVidName = ['Valid_Data_' num2str(validSetIter) '_Session_' num2str(metaIter) '.npy'];
      saveName = [transferDir filesep saveVidName];
      writeNPY(maxDataset, saveName)
      labelName = ['Valid_Labels_' num2str(validSetIter) '_Session_' num2str(metaIter) '.npy'];
      saveLabelName = [transferDir filesep labelName];
      writeNPY(maxLabels, saveLabelName)
      validSetIter = validSetIter + 1;
      mainIter = mainIter + 1;
      maxDataset = [];
      maxLabels = [];
    end

    % Clear variables
    videoArray = [];
    finalMat = [];
    fullVidName = [];
  end
