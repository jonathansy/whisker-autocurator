% Tool for  gathering metrics on autocurator 
function [metrics] = gather_metrics(T, contacts, plotting)


% Loop through trials in T, skip points with no info
numTrials = length(T.trials);
touchDistance = [];
touchKappa = [];
touchVelocity = [];
nonTouchDistance = [];
nonTouchKappa = [];
nonTouchVelocity = [];
touchTheta = [];
nonTouchTheta = [];
for i = 1:numTrials
            % Check that it's curatable
            if isempty(T.trials{i}.whiskerTrial) || ~ismember('whiskerTrial', properties(T.trials{i}))
                continue
            else % Trial safe to preprocess
                poleDownTime = (T.trials{i}.pinDescentOnsetTime -.08)*1000; 
                poleUpTime = T.trials{i}.pinAscentOnsetTime*1000;
                % Sanity check 
                if poleUpTime > 4000
                    poleUpTime = 4000;
                end 
                if poleDownTime >4000
                    poleDownTime = 500;
                end
                touchIdx = contacts{i}.contactInds{1};
                distance = T.trials{i}.whiskerTrial.distanceToPoleCenter{1};
                velocity = diff(distance);
                velocity = [velocity 0 ];
                kappa =  T.trials{i}.whiskerTrial.kappa{1};
                theta = T.trials{i}.whiskerTrial.theta{1};
                % Distance
                newTouchD = distance(touchIdx);
                distance(touchIdx) = [];
                newNonTouchD = distance;
                % Kappa
                newTouchK = kappa(touchIdx);
                kappa(touchIdx) = [];
                newNonTouchK = kappa;
                % Velocity
                newTouchV = velocity(touchIdx);
                velocity(touchIdx) = [];
                newNonTouchV = velocity;
                % Theta 
                newTouchT = theta(touchIdx);
                theta(touchIdx) = [];
                newNonTouchT = theta;
                
            end
            touchDistance = [touchDistance newTouchD];
            touchKappa = [touchKappa newTouchK];
            touchVelocity = [touchVelocity newTouchV];
            nonTouchDistance = [nonTouchDistance newNonTouchD];
            nonTouchKappa = [nonTouchKappa newNonTouchK];
            nonTouchVelocity = [nonTouchVelocity newNonTouchV];
            touchTheta = [touchTheta newTouchT];
            nonTouchTheta = [nonTouchTheta newNonTouchT];
end



% Plotting section 
if plotting == true
    %
    figure(1)
    hold on 
    scatter(touchKappa, touchDistance, 5, 'r', 'filled')
    scatter(nonTouchKappa, nonTouchDistance, 5, 'k', 'filled')
    xlabel('Kappa')
    ylabel('Distance-to-Pole')
    hold off 
    
    figure(2)
    hold on 
    scatter(touchVelocity, touchDistance, 5, 'r', 'filled')
    scatter(nonTouchVelocity, nonTouchDistance, 5, 'k', 'filled')
    xlabel('Velocity')
    ylabel('Distance-to-Pole')
    hold off
    
    figure(3)
    hold on 
    scatter(touchTheta, touchDistance, 5, 'r', 'filled')
    scatter(nonTouchTheta, nonTouchDistance, 5, 'k', 'filled')
    xlabel('Theta')
    ylabel('Distance-to-Pole')
    hold off
    
%     figure(4) 
%     hold on 
%     scatter3(touchVelocity, touchDistance, touchKappa, 5, 'r', 'filled')
%     scatter3(nonTouchVelocity, nonTouchDistance, nonTouchKappa, 5, 'k', 'filled')
%     xlabel('Velocity')
%     ylabel('Distance-to-Pole')
%     zlabel('Kappa')
%     hold off
end

% Output section 
metrics.touchDistance = touchDistance;
metrics.touchKappa = touchKappa;
metrics.touchVelocity = touchVelocity;
metrics.nonTouchDistance = nonTouchDistance;
metrics.nonTouchKappa = nonTouchKappa;
metrics.nonTouchVelocity = nonTouchVelocity;
end