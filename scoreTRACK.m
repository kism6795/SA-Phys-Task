function sa_scores = scoreTRACK(response_data, rate_data, track_data, sa_scores, events, trial_num)
%{
in response_data:
1 = yes
2 = no
%}
%for i = 1:length(rate_data.times)
i = trial_num;
    current_track_status = getTrackStatus(rate_data.times(i,:), events);
    
    %% LEVEL 1 Questions
    if ~isempty(response_data.QID9{i})
        % Is the tracking task in manual mode?
        if str2double(response_data.QID9{i}) == 1 && current_track_status == 1
            % correct if 'yes' & manual mode
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID9{i}) == 2 && current_track_status == 0
            % correct if 'no' & autopilot
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    
    %% LEVEL 2 Questions    
    % none really, hard when you don't get updated position data...
    
    %% LEVEL 3 Questions
    future_manual = getNextMC(rate_data.times(i,:), events);

    if ~isempty(response_data.QID87{i})
        % Do you expect the autopilot to fail soon (within 15 seconds)?
        if str2double(response_data.QID87{i}) == 1 && future_manual == 1
            % correct if 'yes' & at least 1 manual mode is upcoming
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID87{i}) == 2 && current_track_status == 0
            % correct if 'no' & no manual mode is upcoming
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA            
        else
            % incorrect
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end

%% TRACK Functions

function track_status = getTrackStatus(current_time, events)
% Returns current status of the trackings status at the current time using
% the events file

track_status = 0;      % 1 = 'task active'; 0 = autopilot

% get time (sec) for most recent data point
current_time = current_time(1)*60 + current_time(2);

% update tracking status according to each event in the mat file
for i = 1:current_time
    if events.track(i+1) == 1
        track_status = 1;
    elseif events.track(i+1) == 2
        track_status = 0;
    end
end
end

function future_manual = getNextMC(current_time, events)
% Returns whether or not there is an upcoming manual control task in the
% next 30 seconds
future_manual = 0;

% get time (sec) for most recent data point
current_time = current_time(1)*60 + current_time(2);
round_time = floor(current_time);

% update tracking status if there's an event in the mat file 
for i = round_time:round_time+15
    if events.track(i+1) ~= 0
        future_manual = 1;
        return;
    end
end

end