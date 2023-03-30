function sa_scores = scoreCOMM(response_data, rate_data, comm_data, sa_scores, events, trial_num)
%{
in response_data:
1 = yes
2 = no
%}
%for i = 1:length(rate_data.times)
i = trial_num;
    [current_freq, correct_freq] = getRadioStatus(rate_data.times(i,:), comm_data, events);    
    session_status = getSessionStatus(rate_data.times(i,:), events);
    
    %% LEVEL 1 Questions
    if ~isempty(response_data.QID10{i})
        % Is the NAV1 radio set to a frequency lower than 113.000?
        if str2double(response_data.QID10{i}) == 1 && current_freq(1) < 113.000
            % correct if 'yes' & NAV1 less than 113
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID10{i}) == 2 && current_freq(1) >= 113.000
            % correct if 'no' & NAV1 >= 113
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID11{i})
        % Is the NAV2 radio set to a frequency higher than 113.000?
        if str2double(response_data.QID11{i}) == 1 && current_freq(2) > 113.000
            % correct if 'yes' & NAV1 greater than 113
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID11{i}) == 2 && current_freq(2) <= 113.000
            % correct if 'no' & NAV1 <= 113
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID12{i})
        % Is the COM1 radio set to a frequency higher than 127.000?
        if str2double(response_data.QID12{i}) == 1 && current_freq(3) > 113
            % correct if 'yes' & COM1 greater than 127
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID12{i}) == 2 && current_freq(3) <= 113
            % correct if 'no' & COM1 <= 127
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID13{i})
        % Is the COM2 radio set to a frequency lower than 127.000?
        if str2double(response_data.QID13{i}) == 1 && current_freq(4)< 127
            % correct if 'yes' & COM2 less than 127
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID13{i}) == 2 && current_freq(4) >= 127
            % correct if 'no' & COM2 >= 127
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID14{i})
        % Is a communication session active?
        if str2double(response_data.QID14{i}) == 1 && session_status ~= 0
            % correct if 'yes' & active
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2double(response_data.QID14{i}) == 2 && session_status == 0
            % correct if 'no' & inactive
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA            
        else
            % incorrect
        end
    end
    %% LEVEL 2 Questions    
    future_comms = getNextComm(rate_data.times(i,:), events);

    if ~isempty(response_data.QID47{i})
        % Will a comm session end within the next 30 seconds?
        if str2double(response_data.QID47{i}) == 1 && future_comms(2) == 1
            % correct if 'yes' & at least 1 comm sesh is ending
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID47{i}) == 2 && future_comms(2) == 0
            % correct if 'no' & no comm sesh is ending
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID48{i})
        % Will a comm session begin within the next 30 seconds?
        if str2double(response_data.QID48{i}) == 1 && future_comms(1) == 1
            % correct if 'yes' & at least 1 comm sesh is upcoming
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID48{i}) == 2 && future_comms(1) == 0
            % correct if 'no' & no comm sesh is upcoming
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID49{i})
        % Does the NAV1 radio need to be changed?
        if str2double(response_data.QID49{i}) == 1 && current_freq(1) ~= correct_freq(1)
            % correct if 'yes' & current frequency is not correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID49{i}) == 2 && current_freq(1) == correct_freq(1)
            % correct if 'no' & current frequency is  correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID50{i})
        % Does the NAV2 radio need to be changed?
        if str2double(response_data.QID50{i}) == 1 && current_freq(2) ~= correct_freq(2)
            % correct if 'yes' & current frequency is not correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID50{i}) == 2 && current_freq(2) == correct_freq(2)
            % correct if 'no' & current frequency is  correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID51{i})
        % Does the COM1 radio need to be changed?
        if str2double(response_data.QID51{i}) == 1 && current_freq(3) ~= correct_freq(3)
            % correct if 'yes' & current frequency is not correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID51{i}) == 2 && current_freq(3) == correct_freq(3)
            % correct if 'no' & current frequency is  correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA            
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID52{i})
        % Does the COM2 radio need to be changed?
        if str2double(response_data.QID52{i}) == 1 && current_freq(4) ~= correct_freq(4)
            % correct if 'yes' & current frequency is not correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID52{i}) == 2 && current_freq(4) == correct_freq(4)
            % correct if 'no' & current frequency is  correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA            
        else
            % incorrect
        end
    end
    
    
    %% LEVEL 3 Questions

    if ~isempty(response_data.QID88{i})
        % Do you expect to have to change a radio frequency soon (within 30 seconds)?
        if str2double(response_data.QID88{i}) == 1 && future_comms(1) == 1
            % correct if 'yes' & a comm session starts in the next 30
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID88{i}) == 1 && session_status == 1
            % correct if 'yes' & a comm session is active & comm hasn't
            % happened yet
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA            
        elseif str2double(response_data.QID88{i}) == 2 && session_status == 2
            % correct if 'no' & comm has already occurred
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA            
        elseif str2double(response_data.QID88{i}) == 2 && session_status == 0 && future_comms(1) == 0
            % correct if 'no' & no session is active or projected
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA            
        else
            % incorrect
        end
    end


end

%% COMM Functions
function [current_freq, correct_freq] = getRadioStatus(current_time, comm_data, events)
% Returns current correct frequencies and actual frequencies

current_freq = [112.500, 112.500, 126.500, 126.500];
correct_freq = [112.500, 112.500, 126.500, 126.500];

% get time (sec) for most recent data point
current_time = current_time(1)*60 + current_time(2);
count = getLastDatum(comm_data.times, current_time);
round_time = floor(current_time);

% change correct frequency if own-comm event happens that doesn't appear
% later
for i = round_time-30:1:round_time
    if events.comm(i+1) == 2
        switch  events.comm_radio{i+1}
            case 'NAV1'
                correct_freq(1) = str2double(events.comm_freq{i+1});
            case 'NAV2'
                correct_freq(2) = str2double(events.comm_freq{i+1});
            case 'COM1'
                correct_freq(3) = str2double(events.comm_freq{i+1});
            case 'COM2'
                correct_freq(4) = str2double(events.comm_freq{i+1});
        end
    end
end

% adjust each radio that was changed
i = 1;
while i<=count
    if strcmp(comm_data.ship_exp{i},'OWN')
        switch comm_data.radio_exp{i}
            case 'NAV1'
                correct_freq(1) = comm_data.freq_exp(i);
            case 'NAV2'
                correct_freq(2) = comm_data.freq_exp(i);
            case 'COM1'
                correct_freq(3) = comm_data.freq_exp(i);
            case 'COM2'
                correct_freq(4) = comm_data.freq_exp(i);
        end
    end
    
    switch comm_data.radio_act{i}
        case 'NAV1'
            current_freq(1) = comm_data.freq_act(i);
        case 'NAV2'
            current_freq(2) = comm_data.freq_act(i);
        case 'COM1'
            current_freq(3) = comm_data.freq_act(i);
        case 'COM2'
            current_freq(4) = comm_data.freq_act(i);
    end
    i = i+1;
end
end

function session_status = getSessionStatus(current_time, events)
% Returns active session status (1 = active, 0 = not)
session_status = 0;

% get time (sec) for most recent data point
current_time = current_time(1)*60 + current_time(2);
round_time = floor(current_time);

% adjust each time the session status changes
for i = 1:round_time
    if events.comm(i+1) == 2
        session_status = 2;
    elseif events.comm(i+1) == 3
        session_status = 1;
    elseif events.comm(i+1) == 4
        session_status = 0;
    end
end

end

function future_comms = getNextComm(current_time, events)
% Returns session changes within next 30 seconds
future_comms = [0,0]; %[begin i/o, end i/o];

% get time (sec) for most recent data point
current_time = current_time(1)*60 + current_time(2);
round_time = floor(current_time);

% adjust each time the session status changes
end_time = min([round_time+30 length(events.comm)-1]);

for i = round_time:1:end_time
    if events.comm(i+1) == 3 % if an event starts
        future_comms(1) = 1;
    elseif events.comm(i+1) == 4 % if an event ends
        future_comms(2) = 1;
    end
end
end