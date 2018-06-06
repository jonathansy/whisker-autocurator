%WHISKER_MP4_AUTOCURATOR is designed to supplement and eventually replace human curation
%by using machine learning classifiers. This function will use a pre-generated classifier
%and a directory containing the mp4 video files needed curation. Output can either be
%a matrix of logicals sorted by trial or a contact array.

%NOTES: you're gonna need 'normxcorr2' to find the pole

%Begin main function ===========================================================
function [touchArray, confidenceArray, lowConFrames] = whisker_mp4_autocurator(classifier, inputDirectory, outputOptions)
  % Pre-load variables ---------------------------------------------------------
  poleDetectOption = 'auto' %Choose between 'auto', 'coordinates' and 'input'
  logClass = load(classifier);
  %Check if directory exists
  if exist(inputDirectory) == 7
    iDir = inputDirectory;
  else
    error('INPUTDIRECTORY must be a string with a valid directory')
  end
  %See if outputOption specified
  if nargin < 3
    outputOptions = 'matrix';
  end

  % Read video -----------------------------------------------------------------
  %Note, code will read MP4s by default
  vidType = '.mp4';
  vidList = dir([iDir filesep '*' vidType]);
  numVids = length(vidList);
  if numVids == 0
    error('No video files of type %s found in directory', vidType)
  end

  videoArray = cell(1,numVids);

  %Check if parallel possible
  coreNum = feature('numcores')
  if coreNum > 1
    %Use parallel version automatically
    poolobj = gcp('nocreate');
    delete(poolobj);
    parpool(coreNum)
    %Loop through videos and extract frame info into array
    counter = zeros(1, numVids)
    parfor i = 1:numVids
        videoArray{i} = convert_video_to_frames(vidList(i).name)
        videoArray{i} = analyze_video_frames(videoArray{i})
    end

  else
    %Use single for loop
    for i = 1:numVids
      videoArray{i} = convert_video_to_frames(vidList(i).name)

    end
  end
end %===========================================================================

% Subfunction to convert video to array of frames ==============================
% >>> May become independent function in future development <<<
function [outVid] = convert_video_to_frames(inVid)
  currentVid = VideoReader(inVid);
  buildVideoNormal = []; %Create cell array of number of frames to increase speed
  counter = 1;
  while hasFrame(currentVid)
    newFrame = readFrame(currentVid);
    newFrame = newFrame(:,:,1); %RGB values are the same because vid is mono
    buildVideoNormal{counter} = newFrame;
    counter = counter + 1;
    newFrame = [];
  end
  %Put array of video frames into larger array of videos
  outVid.video = buildVideoNormal;
end % ==========================================================================

% Function ot be used on first vid to determine pole location ==================
function [vidInfo] = find_pole_info(firstVideo, findPoleOption, varargin)
  %Note: this function will attempt to find a single pole location using MATLAB's
  % imfindcircle function. Smudges on camera may result in false positives.
  % Inability to find a single pole location automatically will revert to the tried
  % and true method of making humans click on black circles.
  sampleFrame = 1300; %Should be set to a frame where you know the pole will be up
  windowSize = 60; %How many frames across should the image around the pole be
  if nargin > 2
    sampleFrame = varargin{1};
  end
  %And now we determine how to start the pole proceedings
  switch findPoleOption
  case 'coordinates'
    if nargin == 4 && isnumeric(varargin{2})
      poleCoordinates = varargin{4};
    elseif nargin > 4 && isnumeric(varargin{2})
      poleCoordinates(1) = varargin{2};
      if isnumeric(varargin{3})
        poleCoordinates(2) = varargin{4};
      else
        error('You did not supply a Y-coordinate for the pole')
      end
    else
      error('You selected the option to supply pole coordinate but did not input them')
    end
  case 'manual'
    poleCoordinates = click_on_black_circles;
  case 'auto'
    maxAttempts = 20;
    attemptN = 0;
    lRangeStart = 8;
    uRangeStart = 15;
    while attemptN < maxAttempts
      testCoordinates = imfindcircles(firstVideo,[lRangeStart,uRangeStart]);
      if numel(testCoordinates) == 2
        %Found a single match, stop loop
        poleCoordinates = testCoordinates;
        break
      elseif numel(testCoordinates) > 2 && lRangeStart == uRangeStart
        %We failed, stop the iterations
        break
      elseif numel(testCoordinates) > 2
        %Too many results, shrink range
        lRangeStart = lRangeStart + 1;
        uRangeStart = uRangeStart -1;
      elseif numel(testCoordinates) < 2 && lRangeStart == 1
        %Expand only upper range, also, we probably failed
        uRangeStart = uRangeStart + 1;
      elseif numel(testCoordinates) < 2
        %Too few results, increase range
        lRangeStart = lRangeStart - 1;
        uRangeStart = uRangeStart + 1;
      end
      attemptN = attemptN + 1;
    end
    %See if we found a solution
    if ~exist(poleCoordinates)
      poleCoordinates = click_on_black_circles;
    end
  otherwise
    error('Invalid option for pole finding')
  end
    vidInfo.firstpoleCoordiantes = poleCoordinates;
    xRange = [poleCoordinates(2)-(windowSize/2)]:[poleCoordinates(2)+(windowSize/2)-1];
    yRange = [poleCoordinates(1)-(windowSize/2)]:[poleCoordinates(1)+(windowSize/2)-1];
    vidInfo.poleZoomMatrix = firstVideo{sampleFrame}(xRange,yRange);

    %And now it's time for everyones favorite subfunction
    function [poleCoordinates] = click_on_black_circles
      %Initial attempt
      figure(1)
      hold on
      imshow(firstVideo{startFrame})
      title('Please click on the pole')
      hold off
      tempCoordinates = ginput(1)
      clf(1)
      %Check to see if you did it right
      xTemp = [tempCoordinates(2)-(windowSize/2)]:[tempCoordinates(2)+(windowSize/2)-1];
      yTemp = [tempCoordinates(1)-(windowSize/2)]:[tempCoordinates(1)+(windowSize/2)-1];
      figure(1)
      hold on
      imshow(firstVideo{startFrame})
      plot([xTemp(1),xTemp(end)],[yTemp(1),yTemp(1)],'r');
      plot([xTemp(1),xTemp(end)],[yTemp(end),yTemp(end)],'r');
      plot([xTemp(1),xTemp(1)],[yTemp(1),yTemp(end)],'r');
      plot([xTemp(end),xTemp(end)],[yTemp(1),yTemp(end)],'r');
      title('Does this look right to you?')
      hold off
      response = questdlg('Do you wish to accept these coordinates',...
      'Accept coordinates?'...
      'Yes','No','There is no pole in frame')
      %Now we decide how to proceed
      switch response
      case 'Yes'
        poleCoordinates = tempCoordinates;
      case 'No'
        %Go recursive
        poleCoordiantes = click_on_black_circles;
      case 'There is no pole in frame'
        %Adjust sample frame to get one with a pole
        if sampleFrame > 3000
          samepleFrame = sampleFrame - 1000;
        else
          sampleFrame = sampleFrame + 100;
        end
        %Then go recursive
        poleCoordiantes = click_on_black_circles;
      end
end %===========================================================================

% Subfunction to process video with edge detection =============================
%  >>> May become independent function in future development <<<
function [processedVid] = analyze_video_frames(unprocessedVid, poleMatrix)
  %some stuff goes here
  nFrames = length(vid);
for i = 1:nFrames
    aFrames.edge{i} = edge(vid{i});
    aFrames.graph{i} = sum(aFrames.edge{i}(50:end,:));
    aFrames.graph{i} = smooth(aFrames.graph{i},20);
    aFrames.cut{i} = aFrames.edge{i}(205:305,255:355);
    aFrames.cgraph{i} = sum(aFrames.cut{i});
    aFrames.tot(i) = sum(aFrames.cgraph{i});
    aFrames.cgraph{i} = smooth(aFrames.cgraph{i});

end

end %===========================================================================
