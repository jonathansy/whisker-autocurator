% WRITE_TO_CONTACT_ARRAY(NUMPY_LOCATION, CONTACTS, CONTACTARRAY, JOBNAME) takes
% .npy files in NUMPY_LOCATION with curation labels and uses those labels as well
% as preprocessed labels in CONTACTS to write to CONTACTARRAY. JOBNAME is used to
% find the names of the needed files
function write_to_contact_array(npLocation, contactLabels, contactArray, jobName)
  % Handle the contact array
  if exist(contactArray) ~= 2
    error('Cannot find contact array')
  else
    cArray = load(contactArray)
  end

  % Now figure out our labels
  numTrials = length(contactLabels)
  for i = 1:numTrials % We want to iterate by trial
    contactPoints = contactLabels{i}.labels;
    if contactPoints(1) == -1
      continue
      % A negative one indicates that the trial array had no data
      % and we should skip this trial
    end
    searchNum = contactLabels{i}.trialNum;
%     searchNum = searchNum - 217;
%     if searchNum > 211
%         continue 
%     end
    npyName = [ npLocation filesep jobName '_curated_' num2str(searchNum) '_labels.npy'];
    predictions = readNPY(npyName); % Reads a Python npy file into MATLAB
    % Code courtesy of npy-matlab
    iterator = 1; % Need iterator so we don't skip a prediction point when we
    % skip a pre-processed point. There should be less predictions than points
    % in the contact array as a result of our preprocessing. They should go in
    % order. Points needing predictions are marked with a 2.
    for j = 1:numel(contactPoints) %Iterate through each point
      if contactPoints(j) == 2
        iterator = iterator + 1;
        % Use predictions to change
        if predictions(iterator, 1) > predictions(iterator, 2)
          % Touch point
          contactPoints(j) = 1;
        elseif predictions(iterator, 1) < predictions(iterator, 2)
          % Non-touch point
          contactPoints(j) = 0;
        else
          % This means the CNN determined the probability of touch vs non-touch
          % was exactly equal. Empirically we know the CNN is biased towards
          % touches so we will mark as a non-touch. Note that getting this
          % conditional should be HIGHLY unlikely
          contactPoints(j) = 0;
        end
      end
      % If it doesn't equal 2, we skip the point
    end
    conIdx = find(contactPoints == 1) % Extract out indices of touches because
    %that's what the contact array uses
    cArray.contacts{i}.contactInds = conIdx;
  end
  % Save the contact array
  contacts = cArray.contacts;
  params = cArray.params;
  save(contactArray, 'contacts', 'params')
