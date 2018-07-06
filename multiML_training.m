% MULTIML_TRAINING(TARRAYS, METHOD) trains off distance, angle, and curvature
% data in TARRAYS using the matlab machine learning technique specified in
% METHOD
function [model] = multiML_training(tArrays, cArrays, method)

  % The usual input checks
  if ~ischar(method) || sum(strcmp(method, {'logistic', 'tree', 'treebag'})) ~= 1
    error('Invalid method')
  elseif ~iscell(tArrays) && exist(tArrays) ~= 7
    error('Cannot find trial array path')
  elseif iscell(tArrays) && exist(tArrays{1}) ~= 7
    error('Cannot find path of first trial array')
  elseif ~iscell(cArrays) && exist(cArrays) ~= 7
    error('Cannot find trial array path')
  elseif iscell(cArrays) && exist(cArrays{1}) ~= 7
    error('Cannot find path of first trial array')
  end
  if iscell(tArrays) && length(tArrays) ~= length(cArrays)
    error('Must be same number of trial arrays as contact arrays')

  % Extract out tArray data
  if iscell(tArrays)
    [xVars, yLabels] = data_extractor(tArrays, cArrays, true);
  else
    [xVars, yLabels] = data_extractor(tArrays, cArrays, false);
  end

  % Choose method and feed in data
  switch method
  case 'logistic'
    % Perform logistic regression
    featureCoeffs = mnrfit(xVars, yLabels);

  case 'trees'
    % Use decision tree
    tree = fitctree(xVars, yLabels);

  case 'treebag'
    % Use random bag of trees
    bag = TreeBagger(1000, XVars, yLabels);
  end

  % Validation and Test

end

% DATA_EXTRACTOR takes either single or batches of contact arrays
% and trial arrays and formats them into 2-dimensional matrices
% readable by machine learning algorithms
function [xArray, labels] = data_extractor(tArrays, cArrays, multi)
  numFeat = 6; % Change if you incorporate more features
  % Different mode based on whether more than one
  if multi == false
    % Only a single trial/contact pair
    T = load(tArrays);
    T = T.T;
    cVars = load(cArrays);
    contacts = cVars.contacts;
    params = cVars.params;
    xArray = [];
    labels = [];
    % Loop throuh trials
    xArray = zeros(1, numFeat);
    xArray = repmat(xArray, 3000*length(T.trials), 1);
    labels = zeros(1, 3000*length(T.trials));
    newLabels = zeros(1, 4000);
    iter = 1;
    for j = 1:length(T.trials)
      % Indices
      startP = 1 + (iter-1)*3000;
      endP = iter*3000;
      % Go through all reasons to throw out the trial
      if isempty(T.trials{j}.whiskerTrial) || ~ismember('whiskerTrial', properties(T.trials{j}))
        xArray(startP:endP, :) = [];
        labels(startP:endP, 1) = [];
        continue
      elseif isempty(contacts{j}.contactInds) || ~ismember('contactInds', properties(contacts{j}))
        xArray(startP:endP, :) = [];
        labels(startP:endP, 1) = [];
        continue
      else
        iter = iter + 1;
      end
      % Now fill with features
      xArray(startP:endP, 1) = T.trials{j}.whiskerTrial.distanceToPoleCenter{1}(500:3499);
      xArray(startP:endP, 2) = diff(T.trials{j}.whiskerTrial.distanceToPoleCenter{1}(500:3500));
      xArray(startP:endP, 3) = T.trials{j}.whiskerTrial.kappa{1}(500:3499);
      xArray(startP:endP, 4) = T.trials{j}.whiskerTrial.deltaKappa{1}(500:3499);
      xArray(startP:endP, 5) = T.trials{j}.whiskerTrial.theta{1}(500:3499);
      xArray(startP:endP, 6) = diff(T.trials{j}.whiskerTrial.theta{1}(500:3500));
      % Fill labels
      touchIdx = contacts{j}.contactInds;
      newLabels(touchIdx) = 1;
      labels(startP:endP, 1) = newLabels(500:3499);
      newLabels(:) = 0;
    end

  elseif multi == true
    % Multiple pairs in cell array
    xArray = [];
    labels = [];
    for i = 1:length(tArrays)
      T = load(tArrays);
      T = T.T;
      cVars = load(cArrays);
      contacts = cVars.contacts;
      params = cVars.params;
      % Loop throuh trials
      tempX = zeros(1, numFeat);
      tempX = repmat(tempX, 3000*length(T.trials), 1);
      tempY = zeros(1, 3000*length(T.trials));
      newLabels = zeros(1, 4000);
      iter = 1;
      for j = 1:length(T.trials)
        % Indices
        startP = 1 + (iter-1)*3000;
        endP = iter*3000;
        % Go through all reasons to throw out the trial
        if isempty(T.trials{j}.whiskerTrial) || ~ismember('whiskerTrial', properties(T.trials{j}))
          tempX(startP:endP, :) = [];
          tempY(startP:endP, 1) = [];
          continue
        elseif isempty(contacts{j}.contactInds) || ~ismember('contactInds', properties(contacts{j}))
          tempX(startP:endP, :) = [];
          tempY(startP:endP, 1) = [];
          continue
        else
          iter = iter + 1;
        end
        % Now fill with features
        tempX(startP:endP, 1) = T.trials{j}.whiskerTrial.distanceToPoleCenter{1}(500:3499);
        tempX(startP:endP, 2) = diff(T.trials{j}.whiskerTrial.distanceToPoleCenter{1}(500:3500));
        tempX(startP:endP, 3) = T.trials{j}.whiskerTrial.kappa{1}(500:3499);
        tempX(startP:endP, 4) = T.trials{j}.whiskerTrial.deltaKappa{1}(500:3499);
        tempX(startP:endP, 5) = T.trials{j}.whiskerTrial.theta{1}(500:3499);
        tempX(startP:endP, 6) = diff(T.trials{j}.whiskerTrial.theta{1}(500:3500));
        % Fill labels
        touchIdx = contacts{j}.contactInds;
        newLabels(touchIdx) = 1;
        tempY(startP:endP, 1) = newLabels(500:3499);
        newLabels(:) = 0;
      end
      xArray = [xArray; tempX];
      labels = [labels; tempY];
    end
    % Should export xArray as numFeatures x numTrials matrix
  end
end
