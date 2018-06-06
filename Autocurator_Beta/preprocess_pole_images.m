% PREPROCESS_POLE_IMAGES('distance', TARRAY) takes in a trial array and uses distance-to-pole
% metrics to eliminate obvious nontouches, speeding up the time it takes for autocuration
% PREPROCESS_POLE_IMAGES('pixel', IMAGEDIR) will reprocess based on number of pixels
function [contacts] = preprocess_pole_images(inType, var2)
  % Check process method
  switch inType
  case 'distance'
    tArray = var2;
    if exist(tArray) == 0
      error('Cannot find trial array')
    end
    % load trial array for processing
    T = load(tArray);
    numTrials = length(T.trials)
    % Loop through trials and create contacts
    contacts = cell(1);
    for i = 1:numTrials
      % Check that it's curatable
      if isempty(T.trials{i}.whiskerTrial) || ~ismember('whiskerTrial', properties(T.trials{i}))
        warning('Trial number %d has no distance to pole information', i)
        tContacts = zeros(1,4000);
      else % Trial safe to preprocess
        numPoints = length(T.trials{3}.whiskerTrial.distanceToPoleCenter{1});
        tContacts = zeros(1, numPoints);
        medPoint = nanmedian(T.trials{i}.whiskerTrial.distanceToPoleCenter{1})
        for j = 1:numPoints %Loop through each point in trial
          currentPoint = T.trials{i}.whiskerTrial.distanceToPoleCenter{1}(j);
          if currentPoint > medPoint
            tContacts(j) = 0;
          else
            tContacts(j) = -1;
          end
        end
        contacts{i} = tContacts;
      end


  case 'pixel'
    % FUTURE SECTION
    videoDir = var2;
    if exist(videoDir) ~= 7
      error('Cannot find video directory location')
    end

  otherwise
    error('Invalid processing type')
  end

end
