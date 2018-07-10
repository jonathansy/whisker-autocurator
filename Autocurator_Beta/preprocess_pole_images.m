% PREPROCESS_POLE_IMAGES('distance', TARRAY) takes in a trial array and uses distance-to-pole
% metrics to eliminate obvious nontouches, speeding up the time it takes for autocuration
% PREPROCESS_POLE_IMAGES('pixel', IMAGEDIR) will reprocess based on number of pixels
function [contacts] = preprocess_pole_images(inType, var2)
% Check process method
switch inType
    % DISTANCE ONLY ---------------------------------------------------------
    case 'distance'
        T = var2; %The trial array used to preprocess
        if exist('T') == 0
            error('Cannot find trial array')
        end
        % load trial array for processing
        numTrials = length(T.trials);
        % Loop through trials and create contacts
        contacts = cell(1);
        contacts{1}.labels = [];
        contacts{1}.trialNum = [];
        for i = 1:numTrials
            % Check that it's curatable
            if isempty(T.trials{i}.whiskerTrial) || ~ismember('whiskerTrial', properties(T.trials{i}))
                warning('Trial number %d has no distance to pole information', i)
                tContacts = zeros(1,4000);
                tContacts(:) = -1;
            else % Trial safe to preprocess
                numPoints = length(T.trials{i}.whiskerTrial.distanceToPoleCenter{1});
                tContacts = zeros(1, numPoints);
                poleDownTime = (T.trials{i}.pinDescentOnsetTime -.08)*1000; 
                poleUpTime = T.trials{i}.pinAscentOnsetTime*1000;
                % Sanity check 
                if poleUpTime > 4000
                    poleUpTime = 3500;
                end 
                if poleDownTime >4000
                    poleDownTime = 500;
                end
                for j = 1:numPoints %Loop through each point in trial
                    currentPoint = T.trials{i}.whiskerTrial.distanceToPoleCenter{1}(j);
                    % Check if in pole up range
                    if j > poleDownTime && j < poleUpTime
                        inRange = 1;
                    else 
                        inRange = 0;
                    end 
                    % Select based on pole up range and distance to pole
                    if currentPoint > 0.5 || inRange == 0
                        tContacts(j) = 0;
                    else
                        tContacts(j) = 2;
                    end
                end
            end
            contacts{i}.labels = tContacts;
            contacts{i}.trialNum = T.trials{i}.trialNum;
        end
        % PIXEL ONLY ------------------------------------------------------------
    case 'pixel'
%         % FUTURE SECTION
%         T = var2;
%         videoDir = var3;
%         if exist(videoDir) ~= 7
%             error('Cannot find video directory location')
%         end
%         if exist('T') == 0
%             error('Cannot find trial array')
%         end
%         % load trial array for processing
%         numTrials = length(T.trials);
%         % Loop through trials and create contacts
%         contacts = cell(1);
%         contacts{1}.labels = [];
%         contacts{1}.trialNum = [];
%         for i = 1:numTrials
%             contacts{i}.trialNum = T.trials{i}.trialNum;
%             % Check that it's curatable
%             if isempty(T.trials{i}.whiskerTrial) || ~ismember('whiskerTrial', properties(T.trials{i}))
%                 warning('Trial number %d has no distance to pole information', i)
%                 tContacts = zeros(1,4000);
%                 tContacts(:) = -1;
%             else % Trial safe to preprocess
%                 vidList
%             end
%         end
        
        % DISTANCE AND PIXEL
    case 'both'
        
        
    otherwise
        error('Invalid processing type')
end

end
