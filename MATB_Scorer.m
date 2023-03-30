function matb_score = MATB_Scorer(trial_num, subject_folder, date_time)
%% MATB Performance Scorer
%{ 
    Written by Kieran J Smith, kieran.smith@colorado.edu on August 23, 2022 
    as part of a project in conjunction with Draper Labs to score
    objective freeze-probe quizzes designed to assess SA in a modified
    MATB-II task.
%}

%% get trial number


%% set important folders
data_folder = 'SubjectData';
%date_time = '08241241';
%subject_folder = 'Pilot_08-24_jk';
flow_rates = [1000, 500, 800, 400, 500, 500, 700, 800, 800];

%% Import generated XML file
load('events.mat');
events = events2; clear events2

%% Import MATB Data
[rate_data, sysmon_data, track_data, comm_data, resman_data, matb_data] = getMATBdata(date_time, subject_folder, data_folder);


%% score each trial separately
last_datum = ones(1,4);
current_datum = ones(1,4);
matb_score = 0;

% determine prior time
if trial_num > 1
    last_time = (rate_data.times(trial_num-1,1)*60+rate_data.times(trial_num-1,2));
    last_datum(1) = getLastDatum(sysmon_data.times, last_time);
    last_datum(2) = getLastDatum(track_data.times, last_time);
    last_datum(3) = getLastDatum(comm_data.times, last_time);
    last_datum(4) = getLastDatum(resman_data.times, last_time);
end

% determine current time
current_time = (rate_data.times(trial_num,1)*60+rate_data.times(trial_num,2));
current_datum(1) = getLastDatum(sysmon_data.times, current_time);
current_datum(2) = getLastDatum(track_data.times, current_time);
current_datum(3) = getLastDatum(comm_data.times, current_time);
current_datum(4) = getLastDatum(resman_data.times, current_time);

matb_score = scoreTrial(rate_data, sysmon_data, track_data, comm_data, resman_data, events, flow_rates, last_datum, current_datum);

disp(matb_score);

end



%% Score single trial
function penalty_total = scoreTrial(rate_data, sysmon_data, track_data, comm_data, resman_data, events, flow_rates, last_datum, current_datum)
%% scoreSYSMON
penalty_persec = 0.1;
penalty_total = 0;

% add penalty for every second the RT took
if ~isempty(sysmon_data)
    temp_data = sysmon_data.RTs(last_datum(1):current_datum(1));
    penalty_total = penalty_total + penalty_persec*sum(abs(temp_data(~isnan(temp_data))));
    clear temp_data;
end
%penalty_total = penalty_total + penalty_persec*sum(abs(sysmon_data.RTs(~isnan(sysmon_data.RTs(last_datum(1):current_datum(1))))));

%% scoreTRACK

% add penalty for RMSD during each tracking session
%penalty_total = penalty_total + penalty_persec*sum(abs(track_data.RMSD(~isnan(track_data.RMSD(last_datum(2):current_datum(2))))));

if ~isempty(track_data)
    temp_data = track_data.RMSD(last_datum(2):current_datum(2));
    penalty_total = penalty_total + penalty_persec*sum(abs(temp_data(~isnan(temp_data))));
    clear temp_data;
end
%% scoreCOMM

% add penalty for each missed own-comm
%penalty_total = penalty_total + penalty_persec*sum(abs(comm_data.scores(isequal(comm_data.ship_exp(last_datum(3):current_datum(3)),{'OWN'}))));
if ~isempty(comm_data)
    temp_data1 = comm_data.scores(last_datum(3):current_datum(3));
    temp_data2 = comm_data.ship_exp(last_datum(3):current_datum(3));
    penalty_total = penalty_total + penalty_persec*sum(abs(temp_data1(isequal(temp_data2,{'OWN'}))));
    clear temp_data1 temp_data2;
end
%% scoreRESMAN
% initialize fuel levels and pump status for tanks A/B

if ~isempty(resman_data)
    
    count = 1;
    fuel_levels = zeros(length(events.times),2);
    fuel_levels(1,:) = [2500, 2500];
    pump_status = zeros(length(resman_data.times),8);
    
    % set initial flow rates for tanks A & B
    pumps_on = pump_status(1,:) == 1;
    flow_A(1) = -800;
    flow_B(1) = -800;
    
    % start time
    last_current_time = 2;
    
    % determine current time
    temp_time = resman_data.times(current_datum(4),:);
    current_time = floor(temp_time(1)*60+temp_time(2));
    
    for j = last_current_time:current_time  % can't go to event file length bc scores each trial...    
    
        if count <= length(resman_data.times) && j>=(resman_data.times(count,1)*60+resman_data.times(count,2))  
            % if we hit an event, update flow-rates and fuel levels
            fuel_levels(j,:) = resman_data.fuel_levels(count,1:2);
            % update pump status according to event details
            switch resman_data.actions{count}
                case 'On'
                    pump_status(count,resman_data.pumps(count)) = 1;
                case 'Off'
                    pump_status(count,resman_data.pumps(count)) = 0;
                case 'Fail'
                    pump_status(count,resman_data.pumps(count)) = 2;
                case 'Fix'
                    pump_status(count,resman_data.pumps(count)) = 0;
            end
            % determine total flow rates for tanks A & B
            pumps_on = pump_status(count,:) == 1;
            flow_A(j) = pumps_on(1)*flow_rates(1) + pumps_on(2)*flow_rates(2) + pumps_on(8)*flow_rates(8) - pumps_on(7)*flow_rates(7) - 800;
            flow_B(j) = pumps_on(3)*flow_rates(3) + pumps_on(4)*flow_rates(4) + pumps_on(7)*flow_rates(7) - pumps_on(8)*flow_rates(8) - 800;
    
            % increment count
            count = count+1;
        else
            % if no event, flow rate stays unchanged
            flow_A(j) = flow_A(j-1);
            flow_B(j) = flow_B(j-1);
            fuel_levels(j,:) = fuel_levels(j-1,:) + [flow_A(j), flow_B(j)].*1/60;
        end
    end
    
    temp_data1 = fuel_levels(last_current_time:current_time,1);
    temp_data2 = fuel_levels(last_current_time:current_time,2);
    
    nViolations = 0;
    nViolations = nViolations + length(temp_data1(temp_data1>3000));
    nViolations = nViolations + length(temp_data2(temp_data2>3000));
    nViolations = nViolations + length(temp_data1(temp_data1<2000));
    nViolations = nViolations + length(temp_data2(temp_data2<2000));
    last_current_time = current_time;
    clear temp_data1 temp_data2
    
    penalty_total = penalty_total + penalty_persec*sum(nViolations);
end

end