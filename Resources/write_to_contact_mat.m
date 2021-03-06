% WRITE_TO_CONTACT_ARRAY_MAT(NUMPY_LOCATION, CONTACTS) takes
% .npy files in NUMPY_LOCATION with curation labels and uses those labels as well
% as preprocessed labels in CONTACTS to write to a newly generated contact
% array. 
function write_to_contact_mat(npLocation, contactLabels)
  % Get list of .npy files
  npyList = dir([npLocation '/*.npy']);
  npyList = {npyList(:).name};
  numNPYs = length(npyList);
  
  %Create contact array
  cArray = [];
  cArray.contacts = cell(1,length(contactLabels));
  cArray.contacts{1}.prepross = [];
  cArray.contacts{1}.contactInds = [];
  cArray.contacts{1}.contactInds{1} = [];
  cArray.contacts{1}.confidence = [];
  cArray.contacts{1}.trialNum = [];
  
  % Now figure out our labels
  numTrials = length(contactLabels);
  for i = 1:numTrials % We want to iterate by trial
    potentialPoints = contactLabels{i}.labels;
    contactPoints = zeros(1,length(potentialPoints));
    confidence = zeros(size(potentialPoints));
    trialNum = contactLabels{i}.trialNum;
    if potentialPoints(1) == -1
      continue
      % A negative one indicates that the trial array had no data
      % and we should skip this trial
    elseif sum(find(potentialPoints==2)) == 0
        cArray.contacts{trialNum}.contactInds{1} = 'Skipped';
        cArray.contacts{trialNum}.trialNum = contactLabels{i}.trialNum;
        continue
      % Indicates we don't need to do anything here
    end
    searchNum = contactLabels{i}.trialNum;
    
    %Find relevant .npy file
    fullNumpyName = [npLocation filesep contactLabels{i}.video '__curated_labels.npy'];
    predictions = readNPY(fullNumpyName); % Reads a Python npy file into MATLAB
    % Code courtesy of npy-matlab
    iterator = 1; % Need iterator so we don't skip a prediction point when we
    % skip a pre-processed point. There should be less predictions than points
    % in the contact array as a result of our preprocessing. They should go in
    % order. Points needing predictions are marked with a 2.
    for j = 1:numel(potentialPoints) %Iterate through each point
        if potentialPoints(j) == 2 || potentialPoints(j) == 3 % If it doesn't equal 2 or 3, we skip the point
            % Use predictions to change
            if potentialPoints(j) == 3
                %Leftover for rewrites
                contactPoints(j) = 0;
                confidence(j) = 0;
            % NOTE: Added confidence predictors to contact array 
            elseif potentialPoints(j) == 2 && predictions(iterator, 1) > 0.65
                % Non-Touch point
                contactPoints(j) = 0;
                confidence(j) = predictions(iterator, 2);
                iterator = iterator + 1;
            elseif potentialPoints(j) == 2 && predictions(iterator, 1) < 0.65
                % Touch point
                contactPoints(j) = 1;
                confidence(j) = predictions(iterator, 2);
                iterator = iterator + 1;
            else
                % This means the CNN determined the probability of touch vs non-touch
                % was exactly equal. Empirically we know the CNN is biased towards
                % touches so we will mark as a non-touch. Note that getting this
                % conditional should be HIGHLY unlikely
                contactPoints(j) = 0;
                iterator = iterator + 1;
                confidence(j) = 0.5;
            end
        else
            % Leave predetermined points as 0% confidence of touch
            confidence(j) = 0;
        end 
    end
    % Remove lone touches
    loneTouch = strfind(contactPoints, [0, 1, 0]);
    loneTouch = loneTouch + 1;
    contactPoints(loneTouch) = 0;

    conIdx = find(contactPoints == 1); % Extract out indices of touches because
    %that's what the contact array uses
    cArray.contacts{trialNum}.contactInds = [];
    cArray.contacts{trialNum}.prepross = potentialPoints;
    cArray.contacts{trialNum}.contactInds{1} = conIdx;
    cArray.contacts{trialNum}.touchConfidence = confidence;
    cArray.contacts{trialNum}.trialNum = contactLabels{i}.trialNum;
  end
  
  % Save the contact array
  contacts = cArray.contacts;
  %params = cArray.params;
  save('Z:\Users\Jonathan_Sy\JK_Pipeline\JK_Contacts_30.mat', 'contacts')
