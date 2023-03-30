function sa_scores = scoreSYSMON(response_data, rate_data, sysmon_data, sa_scores, events, trial_num)
%{
in response_data:
1 = yes
2 = no
%}
%for i = 1:length(rate_data.times)
i = trial_num;
    current_light_status = getLightStatus(rate_data.times(i,:), sysmon_data.times, sysmon_data.F_num, sysmon_data.RTs, events);
    current_last_lights = getLastFailures(rate_data.times(i,:), sysmon_data.times, sysmon_data.F_num, sysmon_data.RTs, events);
    
    
    %% LEVEL 1 Questions
    if ~isempty(response_data.QID2{i})
        % Is the F5 warning light green?
        % green = 'off', white = 'on'
        if str2double(response_data.QID2{i}) == 1 && current_light_status(5) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID2{i}) == 2 && current_light_status(5) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID3{i})
        % Is the F6 warning light red?
        % red = 'on', white = 'off'
        if str2double(response_data.QID3{i}) == 1 && current_light_status(6) == 1
            % correct if 'yes' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID3{i}) == 2 && current_light_status(6) == 0
            % correct if 'no' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID4{i})
        % Is the F1 scale centered?
        % centered = 'off'
        if str2double(response_data.QID4{i}) == 1 && current_light_status(1) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID4{i}) == 2 && current_light_status(1) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID5{i})
        % Is the F2 scale centered?
        % centered = 'off'
        if str2double(response_data.QID5{i}) == 1 && current_light_status(2) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID5{i}) == 2 && current_light_status(2) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID6{i})
        % Is the F3 scale centered?
        % centered = 'off'
        if str2double(response_data.QID6{i}) == 1 && current_light_status(3) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID6{i}) == 2 && current_light_status(3) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID7{i})
        % Is the F4 scale centered?
        % centered = 'off'
        if str2double(response_data.QID7{i}) == 1 && current_light_status(4) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID7{i}) == 2 && current_light_status(4) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    
    %% LEVEL 2 Questions    
    if ~isempty(response_data.QID39{i})
        % Is the F5 warning light nominal?
        % nominal = 'off'
        if str2double(response_data.QID2{i}) == 1 && current_light_status(5) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID2{i}) == 2 && current_light_status(5) == 1
            % correct if 'no' and 'on'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID40{i})
        % Is the F6 warning light nominal?
        % nominal = 'off'
        if str2double(response_data.QID40{i}) == 1 && current_light_status(6) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID40{i}) == 2 && current_light_status(6) == 1
            % correct if 'no' and 'on'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID41{i})
        % Is the F1 warning scale nominal?
        % nominal = 'off'
        if str2double(response_data.QID41{i}) == 1 && current_light_status(1) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID41{i}) == 2 && current_light_status(1) == 1
            % correct if 'no' and 'on'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID42{i})
        % Is the F2 warning scale nominal?
        % nominal = 'off'
        if str2double(response_data.QID42{i}) == 1 && current_light_status(2) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID42{i}) == 2 && current_light_status(2) == 1
            % correct if 'no' and 'on'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID43{i})
        % Is the F3 warning scale nominal?
        % nominal = 'off'
        if str2double(response_data.QID43{i}) == 1 && current_light_status(3) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID43{i}) == 2 && current_light_status(3) == 1
            % correct if 'no' and 'on'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID44{i})
        % Is the F4 warning scale nominal?
        % nominal = 'off'
        if str2double(response_data.QID44{i}) == 1 && current_light_status(4) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID44{i}) == 2 && current_light_status(4) == 1
            % correct if 'no' and 'on'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID46{i})
        % Is the autopilot currently operating on the secondary flight computer?
        % 0 = 'off' = nominal
        if str2double(response_data.QID44{i}) == 1 && current_light_status(5) == 1 &&  current_light_status(6) == 0
            % correct if 'yes' and F5 is on and F6 is nominal
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID44{i}) == 2 && current_light_status(5) == 0
            % correct if 'no' and F5 is nominal
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID44{i}) == 2 && current_light_status(6) == 1
            % correct if 'no' and F6 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    %% LEVEL 3
    upcoming_failures = getNextFailures(rate_data.times(i,:), events);

    if ~isempty(response_data.QID89{i})
        % Do you expect pump 1 to fail within the next 15 seconds?
        if str2double(response_data.QID89{i}) == 1 && upcoming_failures(1) == 1
            % correct if 'yes' and P1 has an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID89{i}) == 2 && upcoming_failures(1) == 0
            % correct if 'no' and P1 does not have an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID90{i})
        % Do you expect pump 2 to fail within the next 15 seconds?
        if str2double(response_data.QID90{i}) == 1 && upcoming_failures(2) == 1
            % correct if 'yes' and P3 has an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID90{i}) == 2 && upcoming_failures(2) == 0
            % correct if 'no' and P3 does not have an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID91{i})
        % Do you expect pump 3 to fail within the next 15 seconds?
        if str2double(response_data.QID91{i}) == 1 && upcoming_failures(3) == 1
            % correct if 'yes' and P3 has an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID91{i}) == 2 && upcoming_failures(3) == 0
            % correct if 'no' and P3 does not have an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID92{i})
        % Do you expect pump 4 to fail within the next 15 seconds?
        % nominal = 'off'
        if str2double(response_data.QID92{i}) == 1 && upcoming_failures(4) == 1
            % correct if 'yes' and P1 has an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID92{i}) == 2 && upcoming_failures(4) == 0
            % correct if 'no' and P1 does not have an upcoming failure
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end

%% SYSMON Functions
function light_status = getLightStatus(current_time, light_times, lights, RTs, events)
% Returns the light states at the 'current_time' using the
% reaction time data from the last 15 seconds
light_status = zeros(1,6);

% get index for most recent data point
current_time = current_time(1)*60 + current_time(2);
count = getLastDatum(light_times, current_time);

% update light status according to each event within last 15 sec
%{
neat little detail: MATB auto fails you and fixes the issue if it's 
    off-nominal during the questionnaires. it also does not record the
    light alert UNTIL you've failed to respond (after questionnaires are
    done)

SO: if there was a sysmon event in events.mat and it did not appear in the
    MATB data, then there is an open light (light_status = 1); if there was a
    sysmon event in the mat file and it DOES appear with a reaction time,
    then there is not an open light (light_status = 0), and same if there's
    no sysmon event at all.
%}
% turn on each light that has been switched on (accord to .mat file)
round_time = floor(current_time);
for i = round_time-15:1:round_time
    if events.sysmon(i+1) ~= 0
        light_status(events.sysmon(i+1)) = 1;   % 1 = 'on' = needs to be clicked
    end
end

% turn off each light that was reacted to
i = count;
seconds_since = (current_time - (light_times(i,1)*60 + light_times(i,2)))/60;
while i>0 && seconds_since < 15 % time that errors last for before defaulting
    if ~isnan(RTs(count))   
        % if the RT shows that the light has been resolved
        if RTs(count) > 0 && RTs(count) < seconds_since 
            light_status(lights(i)) = 0;    % 0 = 'off' = nominal
        end
    end
    seconds_since = (current_time - (light_times(i,1)*60 + light_times(i,2)))/60;
    i = i-1;
end


end

function last_lights = getLastFailures(current_time, light_times, lights, RTs, events)
% Returns the most recent time each system went off-nominal (or returns
% -1 if it hsan't happened yet)
last_lights = -1*ones(1,6);

% get index for most recent data point
current_time = current_time(1)*60 + current_time(2);

% update light status according to each event in the mat file
for i = 1:current_time
    if events.sysmon(i+1) ~= 0
        last_lights(events.sysmon(i+1)) = events.times(i+1);
    end
end

end

function future_fails = getNextFailures(current_time, events)
% Returns whether or not (1/0) pumps 1-4 have upcoming failures within the 
% next 15 seconds
future_fails = zeros(1,4);

% get index for most recent data point
current_time = current_time(1)*60 + current_time(2);
round_time = floor(current_time);

% update pump status according to each event within next 15 sec
for i = round_time:round_time+15
    if events.resman(i+1) >= 1 && events.resman(i+1) <= 4
        future_fails(events.resman(i+1)) = 1;
    end
end


end

