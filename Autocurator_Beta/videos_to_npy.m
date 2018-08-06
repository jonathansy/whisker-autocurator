function [newContacts] =videos_to_npy(contacts, videoDir, saveDir, writeYes)
  % Check existance
  if exist(videoDir) ~= 7
    error('Cannot find video directory')
  elseif exist(saveDir) ~= 7
    error('Cannot find saving directory')
  end
  samplePoleImage = 'C:\SuperUser\Code\ML_whisker_image_dev\samplePoleMat';

  % Establish number of trials in contacts and number of videos
  numTrials = length(contacts);
  vList = dir([videoDir '/*.mp4']); % Get list of mp4s
  videoList = {vList(:).name};
  numVideos = length(videoList);

%   % Begin loop
%   averages = [];
%   avgIter = 1;
  for i = 1:numTrials
    % Find indices of frames we need to curate
    labels = contacts{i}.labels;
    twoIdx = find(labels == 2);
    threeIdx = find(labels == 3);
    relevantIdx = [twoIdx threeIdx];
    relevantIdx = sort(relevantIdx);
    % Skip trial if nothing to curate
    if isempty(relevantIdx)
      continue
    end

    % Find corresponding video
    trialNum = contacts{i}.trialNum;
    if strcmp(contacts{i}.video, 'null')
        continue 
    else
        fullVidName = [videoDir filesep contacts{i}.video '.mp4'];
    end
    
% OUTDATED SECTION FOR FINDING VIDEOS, USE IF NO trackerfileNames
%     for j = 1:numVideos
%       videoName = videoList{j};
%       exprNum = '[0123456789]+.mp4';
%       resultStr = regexp(videoName, exprNum, 'match'); %Should return #.mp4
%       numStr = resultStr{1}(1:(end-4)); %Strip '.mp4' to leave just video number
%       vidNumber = str2num(numStr);
%       if vidNumber == trialNum
%         fullVidName = [videoDir filesep videoName];
%         break
%       else
%         continue
%       end
%     end
    
    % If for some reason no video, skip
    if ~exist(fullVidName)
      continue
    end

    % Load with mmread
    videoArray = mmread(fullVidName);

    % Find pole location in video
    sPM = load(samplePoleImage); % Saved picture of pole
    samplePoleMat = sPM.samplePoleMat;
    % The below is an absurdly stupid solution to a randomly occuring 
    % MATLAB error regarding improper indexing
    try
        testFrame = videoArray.frames(1500).cdata(:,:,1);
    catch
        % Yes you can do the same thing and the error does not reappear
        testFrame = videoArray.frames(1500).cdata(:,:,1);
    end
    corrPoints = normxcorr2(samplePoleMat, testFrame(:,:,1));
    [yCorr, xCorr] = find(corrPoints==max(corrPoints(:)));
    xPole = xCorr - (size(samplePoleMat, 2) /2);
    yPole = yCorr - (size(samplePoleMat, 1) /2);
    poleBox = [yPole-30, yPole+30, xPole-30, xPole+30];
    
    [~,maxSize] = size(videoArray.frames);
    relevantIdx(relevantIdx > maxSize) = [];
    
    %Edge detection to determine if whisker in frame ----------------------
    newRel = zeros(1, numel(relevantIdx));
    for k = 1:numel(relevantIdx)
        findFrame = videoArray.frames(relevantIdx(k)).cdata(:,:,1);
        eFrame = edge(findFrame);
        eFrameClose = eFrame((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
        topSide = mean(mean(eFrameClose(1:15,1:46)));
        rightSide = mean(mean(eFrameClose(1:46,47:61)));
        %         avg = mean(topSide + rightSide);
        %         averages(avgIter) = avg;
        %         avgIter = avgIter + 1;
        if mean(topSide + rightSide) > 0.02 && contacts{i}.labels(relevantIdx(k)) == 3
            contacts{i}.labels(relevantIdx(k)) = 2;
        elseif contacts{i}.labels(relevantIdx(k)) == 2
            %Nothing 
        else 
            contacts{i}.labels(relevantIdx(k)) = 0;
            newRel(k) = 1;
        end
    end
    relevantIdx(newRel == 1) = [];
    % ---------------------------------------------------------------------
    
    % Prep loop
    numRelFrames = numel(relevantIdx);
    finalMat = zeros(numRelFrames,61);
    finalMat = repmat(finalMat, 1,1,61);

    % Frame loop
    for k = 1:numRelFrames
      curIdx = relevantIdx(k);
      curFrame = videoArray.frames(curIdx).cdata(:,:,1);
      nFrameMat = curFrame((poleBox(1)):(poleBox(2)),(poleBox(3)):(poleBox(4)));
      finalMat(k,:,:) = nFrameMat;
    end

    % Save as npy file
    saveName = contacts{i}.video;
    saveName = [saveDir filesep saveName '_dataset.npy'];
    if writeYes == true
        writeNPY(finalMat, saveName)
    end
    
    % Clear variables
    videoArray = [];
    finalMat = [];
    fullVidName = [];
    videoName = [];
  end
  
  newContacts = contacts;
