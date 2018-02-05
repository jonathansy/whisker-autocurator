%FIND_POLE_INFO(FIRSTVIDEO,FINDPOLEOPTION) will return an output VIDINFO with
%datafields for pole coordinates as well as a pole matrix that can be used to
%find poles in other frames using the NORMXCORR2 command.

function [vidInfo] = find_pole_info(sampleVideo, findPoleOption, varargin)
  %Note: this function will attempt to find a single pole location using MATLAB's
  % imfindcircle function. Smudges on camera may result in false positives.
  % Inability to find a single pole location automatically will revert to the tried
  % and true method of making humans click on black circles.
  sampleFrame = 1500; %Should be set to a frame where you know the pole will be up
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
    uRangeStart = 17;
    edgeTest = edge(sampleVideo{sampleFrame});
    while attemptN < maxAttempts
      testCoordinates = imfindcircles(edgeTest,[lRangeStart,uRangeStart]);
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
    if ~exist('poleCoordinates')
      poleCoordinates = click_on_black_circles;
    end
  otherwise
    error('Invalid option for pole finding')
  end
    vidInfo.firstpoleCoordiantes = poleCoordinates;
    xRange = [(poleCoordinates(2)-(windowSize/2)):(poleCoordinates(2)+(windowSize/2)-1)];
    xRange = ceil(xRange);
    yRange = [(poleCoordinates(1)-(windowSize/2)):(poleCoordinates(1)+(windowSize/2)-1)];
    yRange = ceil(yRange);
    vidInfo = sampleVideo{sampleFrame}(xRange,yRange);

    %And now it's time for everyones favorite subfunction
    function [poleCoordinates] = click_on_black_circles
      %Initial attempt
      figure(1)
      hold on
      imshow(sampleVideo{sampleFrame})
      title('Please click on the pole')
      hold off
      tempCoordinates = ginput(1)
      %clf(1)
      %Check to see if you did it right
      xTemp = [tempCoordinates(2)-(windowSize/2)]:[tempCoordinates(2)+(windowSize/2)-1];
      yTemp = [tempCoordinates(1)-(windowSize/2)]:[tempCoordinates(1)+(windowSize/2)-1];
      figure(1)
      hold on
      imshow(sampleVideo{sampleFrame})
      plot([xTemp(1),xTemp(end)],[yTemp(1),yTemp(1)],'r');
      plot([xTemp(1),xTemp(end)],[yTemp(end),yTemp(end)],'r');
      plot([xTemp(1),xTemp(1)],[yTemp(1),yTemp(end)],'r');
      plot([xTemp(end),xTemp(end)],[yTemp(1),yTemp(end)],'r');
      title('Does this look right to you?')
      hold off
      response = questdlg(['Do you wish to accept these coordinates',...
      'Accept coordinates?'...
      'Yes','No','There is no pole in frame']);
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
    end
end %===========================================================================
