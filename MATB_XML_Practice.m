%% Practice MATB XML Generator
%{ 
    Written by Kieran J Smith, kieran.smith@colorado.edu on August 2, 2022 
    as part of a project in conjunction with Draper Labs to generate XML 
    files for a modified version of the MATB-II task with additional 
    interactions between tasks so as to better study the comprehension and
    projection levels of Situation Awareness (as defined by Endsley)
%}
%{
things to implement:
1) tie F1-F4 failures to P1-P4 failures
- delay P by 5-10 seconds (random)

2) tie combination of F5-F6 failure to manual tracking
- occurs if F5 & F6 fail within 10 sec
- manual control engage 10-15 sec after 2nd
- shorter duration, resolves ~20 seconds

3) tie 'Other' comm events to manual tracking
- occurs sometimes if 1+ 'Other' comm event
  within 30 sec
- the more, the more likely
- tracking can start within 30 sec of 1st comm event
- longer duration, 30-40 sec

4) force low fuel level by 
- make pump rates all lower than drain rate
- fail >1 pump for extended duration
- start manual tracking when fuel level drops low
- determine how long this takes!!
%}
tic;
subj_num = 'Practice';
test_date = '091522';

nTrials = 1;
trialLength = 120;
totalLength = trialLength*nTrials;
nEvents = 10; % baseline # of primary events


data_folder = 'SubjectData';
subject_folder =  'Practice';
%sprintf('Subject-%s-%s',subj_num,test_date);

write_files = 'on';
XML_file_name = fullfile('..\',data_folder,subject_folder,'MATB_EVENTS_PRACTICE.xml');
Event_file_name = fullfile('..\',data_folder,subject_folder,'PRACTICE_EVENTS_MATLAB.txt');
event_mat_name = fullfile('..\',data_folder,subject_folder,'events.mat');

if strcmp(write_files,'off')
    XML_file_name = 'test_xml.xml';
    Event_file_name = 'test_events.txt';
end

% adding 30 seconds for events to resolve themselves
times = [0:totalLength+30]';
sysmon = zeros(totalLength+31,1);
resman = zeros(totalLength+31,1);
track = zeros(totalLength+31,1);
comm = zeros(totalLength+31,1);
rate = zeros(totalLength+31,1);
events = table(times, sysmon, track, comm, resman, rate);

%% set rate times to 2 minutes +/- 15 seconds
% trials should be of random lengths (to some degree) so that subjects
% don't know when to memorize everything for SA questionnaires
% trials range from 1:50 to 2:10
rng(2); % set seed (for now at least)
rate_offset = 0;
rate_offsets = round(rand(1,nTrials)*rate_offset*2-rate_offset + 1); % +1 because of time zero
if rate_offsets(end) > 0       
    rate_offsets(end) = 0;  % so that total length always = 20 minutes
end
rate_times = [trialLength:trialLength:trialLength*nTrials] + rate_offsets; % every 2 minutes +/- offset
events.rate(rate_times+1) = 1; % a 1 indicates rate event should be added

trial_lengths = rate_times; % calculate trial lengths
for i = 2:nTrials
    trial_lengths(i) = rate_times(i)-rate_times(i-1);
end

%% Set trial parameters
trialNum = [1:nTrials]';
trialOrder = randperm(nTrials); % randomize trial order

% set up so that we get every combo of taskload, motivation, and complexity
taskLoad = 0;
motivation = 1;
memoryLoad = 0;
trial_params = table(trialNum,taskLoad(trialOrder),motivation(trialOrder),...
    memoryLoad(trialOrder));
trial_params.Properties.VariableNames = {'trialNum','taskLoad',...
    'motivation','memoryLoad'};

%% Set Primary Events
% defines which events will occur in what order and in which trial
%{
task load:
    0: 10 events/trial
    1: 20 events/trial

primary events:
    1. single F1-F4 failure             |	SYSMON 1-4
    2. single F5-F6 failure             |	SYSMON 5-6
    3. single P5-P8 failure             |	RESMAN 5-8 
    4. single other plane radio         |   COMM 1
    5. self plane radio                 |   COMM 2
%}
event_codes = zeros(nTrials,nEvents*2); % sequence of events codes on each trial
event_times = zeros(nTrials,nEvents*2); % times of events on each trial
event_likelihoods = [0.15, 0.3, 0.15, 0.24, 0.16]; % likelihoods for each primary event 
for i = 1:length(event_likelihoods)
    event_cdf(i) = sum(event_likelihoods(1:i));
end

if event_cdf(end) ~= 1
    warning('CDF doesn''t sum to 1: Double check your event likelihoods (Line 96)');
end

for i = 1:nTrials
    % double the number of events on high task load trials
    nTotal(i) = nEvents*(trial_params.taskLoad(i)+1);
    
    % randomly select specific events
    for j = 1:nTotal(i)
        temp_rand = rand();
        k = 1;
        while temp_rand >= event_cdf(k)
            k = k + 1;
        end
        event_codes(i,j) = k;
    end
    
    % select times for each event to occur at
    % split trials into nEvents intervals and select a random time w/in each
    for j = 1:nTotal(i)
        interval = trial_lengths(i)/nTotal(i);
        if i == 1   % if first trial
            event_times(i,j) = round(interval*(j-1) + rand()*interval);
        else        % otherwise add last rate time to event time
            event_times(i,j) = round(interval*(j-1) + rand()*interval + rate_times(i-1));
        end
    end
end

trial_params.eventCodes = event_codes;
trial_params.eventTimes = event_times;

%% Create Primary Event Files
% generates specific event files for use in creating XML files later
%{
SYSMON 
    0: no event
    1: event F1
    2: event F2
    3: event F3
    4: event F4
    5: event F5
    6: event F6
RESMAN
    5: error pump 5
    6: error pump 6
    7: error pump 7
    8: error pump 8
COMM
    0: no event
    1: OTHER comm event
    3: COMM Session START
%}

% double computer failure max delay time
maxCPUdelay = 10;

% time between complex event and manual tracking start
manualTrackDelay = 5;

% time between two other comm events
% (8, 7) gives random number between 9 and 15
minCommDelay = 8;
commDelayRange = 7;
commWindowRange = 20;

% function randDelay = randomDelay(event_category,event_time,existing_delay,rand_range,rand_start)

for i = 1:nTrials
    for j = 1:nEvents*2
        switch event_codes(i,j)
            case 1 % Single F1-F4 Failure
                events.sysmon(event_times(i,j)+1) = randi(4);

            case 2  % Single F5-F6 Failure
                events.sysmon(event_times(i,j)+1) = randi(2)+4;
               
            case 3  % Single P5-P8 Failure
                events.resman(event_times(i,j)+1) = randi(4)+4;
               
            case 4  % Single Other Comm
                events.comm(event_times(i,j)+1) = 1;

            case 5  % Single Self Comm
                events.comm(event_times(i,j)+1) = 3;
        end
    end
end


%% Add in secondary events!
%{
secondary events:
    1. double computer failure within 10 sec --> manual tracking within 15 sec      
            if SYSMON 5 & SYSMON 6 w/in 10 --> TRACK 1 w/in 15
    2. multiple other planes within 30 sec --> manual tracking within 15 sec
            if COMM 1 & COMM 1 w/in 30 --> TRACK 1 w/in 15
    3. main pump power deviation --> main pump failure within 10 sec
            if SYSMON 1-4 --> RESMAN 1-4 w/in 10
    4. main pump failure --> main pump fix within 10 sec
            if SYSMON 1-4 --> RESMAN 1-4 w/in 10
    5. comm session start --> comm event --> comm session stop
            if COMM 3 --> COMM 2 --> COMM 4
%}


% function randDelay = randomDelay(event_category,event_time,existing_delay,rand_range,rand_start)

%  set event durations
pump_fail_duration_range = 7; pump_fail_duration_start = 5; % random number from 6 to 12 for all trials
manual_track_duration_range = 11; manual_track_duration_start = 14; % random number from 15 to 25 for all trials
flightCPU_event_delay = 15;
otherPlane_event_delay = 30;
comm_sesh_length = 30;

% tracks last occurence of certain events
comm_status = 0;
last_other_comm = -totalLength;
last_f5 = -totalLength;
last_f6 = -totalLength;
own_comm_timer = 0;
delete_next_comm_stop = 0;

for i = 1:(totalLength+1)
    % determine what mental load level the trial is
    j = 1;
    
    % set random ranges for events to occur after their trigger depending on memoryLoad
    if trial_params.memoryLoad(j) == 0
        delay_range = 4; delay_start = 1; % random number from 2 to 5 for low WM trials
        comm_sesh_range = 5; comm_sesh_start = 5; % random number from 6 to 10 for low WM trials
    elseif trial_params.memoryLoad(j) == 1 
        delay_range = 4; delay_start = 11; % random number from 12 to 15 for high WM trials
        comm_sesh_range = 5; comm_sesh_start = 15; % random number from 16 to 20 for low WM trials
    end
    
    % check for sysmon events
    if events.sysmon(i) ~= 0    
        if events.sysmon(i) < 5         % F1-F4 gauges
            % ensure we don't dump an event on top of another
            randDelay = randomDelay(events.resman,events.times(i),0,delay_range,delay_start);
            % start pump failure after random delay
            events.resman(events.times(i)+randDelay) = events.sysmon(i);                        
            
            % ensure we don't dump an event on top of another
            randDuration = randomDelay(events.resman,events.times(i),randDelay,pump_fail_duration_range,pump_fail_duration_start);
            % resolve pump failure after random duration
            events.resman(events.times(i)+randDelay+randDuration) = events.sysmon(i)+8;                             
    
        elseif events.sysmon(i) == 5         % F5 (Primary Flight Computer) failure
            last_f5 = events.times(i);      
            if (events.times(i) - last_f6) < flightCPU_event_delay    % if it's been less than 10 sec since last f6 event           
                % ensure we don't dump event on top of another
                manualTrackDelay = randomDelay(events.track,events.times(i),0,delay_range,delay_start);
                manualTrackDuration = randomDelay(events.track,events.times(i),manualTrackDelay,manual_track_duration_range,manual_track_duration_start);
                % start tracking event after random manualTrackDelay based on MWL
                events.track(events.times(i) + manualTrackDelay) = 1;
                % end tracking event after random manualTrackDuration
                events.track(events.times(i) + manualTrackDelay + manualTrackDuration) = 2;
                % require brand new f5 event to trigger another event
                last_f5 = -totalLength;
                                
            end
                
        elseif events.sysmon(i) == 6        % F6 (Secondary Flight Computer) failure
            last_f6 = events.times(i);
            if (events.times(i) - last_f5) < flightCPU_event_delay    % if it's been less than 10 sec since last f6 event
            	% ensure we don't dump event on top of another
                manualTrackDelay = randomDelay(events.track,events.times(i),0,delay_range,delay_start);
                manualTrackDuration = randomDelay(events.track,events.times(i),manualTrackDelay,manual_track_duration_range,manual_track_duration_start);
                % start tracking event after random manualTrackDelay based on MWL
                events.track(events.times(i) + manualTrackDelay) = 1;
                % end tracking event after random manualTrackDuration
                events.track(events.times(i) + manualTrackDelay + manualTrackDuration) = 2;
                last_f6 = -totalLength;                            % require brand new f5 event to trigger another event
            end
        end
    end

    if events.comm(i) ~= 0      % check for comm events
        if events.comm(i) == 1          % OTHER comm event 
            if own_comm_timer == 0       % (only if we're not currently getting a comm event)
                if events.times(i) - last_other_comm < 30       % if its been less than 30 sec since last other comm
                    % trigger manual tracking event:
                    % ensure we don't dump event on top of another
                    manualTrackDelay = randomDelay(events.track,events.times(i),0,manual_track_duration_range,manual_track_duration_start);
                    manualTrackDuration = randomDelay(events.track,events.times(i),manualTrackDelay,manual_track_duration_range,manual_track_duration_start);
                    % start tracking event after random manualTrackDelay based on MWL
                    events.track(events.times(i) + manualTrackDelay) = 1;
                    % end tracking event after random manualTrackDuration
                    events.track(events.times(i) + manualTrackDelay + manualTrackDuration) = 2;
                                        
                    last_other_comm = -totalLength;
                else            % if this is the first other comm in 30 seconds
                    last_other_comm = events.times(i);          % set this to be the last other comm :-)

                end
            
            elseif own_comm_timer ~= 0   % if we're in the middle of a self-comm event
                events.comm(i) = 0;                            % delete the "Other" event
            end
        elseif events.comm(i) == 3  % START COMM Session
            if  comm_status == 0      % if not already in a comm session
                % start one
                comm_status = 1;      
                % find an open slot within 20 seconds
                commStartDelay = randomDelay(events.comm,events.times(i),0,comm_sesh_length,0);                
                % schedule an own comm event
                events.comm(events.times(i)+commStartDelay) = 2;
                
                % find an open slot within 20 seconds
                commEndDelay = randomDelay(events.comm,events.times(i),commStartDelay,comm_sesh_length,0); 
                % schedule a comm session end
                events.comm(events.times(i)+commStartDelay+commEndDelay) = 4;

            elseif comm_status == 1                         % delete 'start' comm event session if already in one
                events.comm(i) = 0;
                
            end
        elseif events.comm(i) == 2      % OWN comm event
            if own_comm_timer == 0                          % if we're not already hearing a self-comm
                own_comm_timer = 11;                        % no other comm events for 11 seconds to allow audio file to play
            else
                events.comm(i) = 0;                         % delete comm event if it overlaps another
            end
        elseif events.comm(i) == 4  % STOP COMM Session
            if comm_status == 0                             % delete comm event stop session if already stopped
                events.comm(i) = 0;
            end
            comm_status = 0; % turn off comm status
        end
    end
    
    if events.resman(i) ~= 0    % check for resman events
        if events.resman(i) >= 5 && events.resman(i) <= 8   % P5-P8 events
            % add fix event
            % ensure we don't dump an event on top of another
            randDuration = randomDelay(events.resman,events.times(i),0,pump_fail_duration_range,pump_fail_duration_start);
            % resolve pump failure after random duration
            events.resman(events.times(i)+randDuration) = events.resman(i)+8; 
        end
    end
    
    % count down timer
    if own_comm_timer > 0
        own_comm_timer = own_comm_timer - 1;
    end
    
end

% remove any events that occur after the end
events = events(1:totalLength+1,:);

% ensure tracking gets turned off at the end
events.track(totalLength+1) = 2;
%% CREATE XML File and report file
%{
SYSMON 
    0: no event
    1: event F1
    2: event F2
    3: event F3
    4: event F4
    5: event F5
    6: event F6
RESMAN
    0: no event
    1: error pump 1
    2: error pump 2
    3: error pump 3
    4: error pump 4
    5: error pump 5
    6: error pump 6
    7: error pump 7
    8: error pump 8
    9: resolve pump 1
    10: resolve pump 2
    11: resolve pump 3
    12: resolve pump 4
    13: resolve pump 5
    14: resolve pump 6
    15: resolve pump 7
    16: resolve pump 8
COMM
    0: no event
    1: OTHER comm event
    2: OWN comm event
    3: COMM Session START
    4: COMM Session STOP
TRACK
    0: no event (autopilot)
    1: manual tracking on
    2: autopilot on
%}

% set potential comm signals
other = table([118.325; 120.825; 124.350; 126.175; 127.725; 128.525; 130.875; 132.950; 134.175; 135.225],...
              [118.275; 120.775; 124.500; 126.025; 127.675; 128.475; 130.725; 132.800; 134.025; 135.175],...
              [108.350; 109.250; 110.400; 111.950; 112.150; 113.000; 114.500; 115.750; 116.450; 117.650],...
              [108.750; 109.650; 110.800; 111.350; 112.550; 113.400; 114.900; 115.050; 116.850; 117.950]);
other.Properties.VariableNames = {'COM1','COM2','NAV1','NAV2'};

own = table([124.575; 125.500; 125.550; 126.450; 126.525; 127.500; 127.550; 128.475; 128.575; 129.450],...
            [124.450; 125.500; 125.575; 126.475; 126.550; 127.500; 127.525; 128.525; 128.550; 129.575],...
            [110.650; 111.500; 111.600; 112.450; 112.550; 113.500; 113.600; 114.450; 114.650; 115.400],...
            [110.500; 111.400; 111.650; 112.450; 112.600; 113.500; 113.550; 114.450; 114.600; 115.650]);
own.Properties.VariableNames = {'COM1','COM2','NAV1','NAV2'};

% shuffle order of radio calls
radio_order = repmat([1,2,3,4],1,10)';
radio_order = radio_order(randperm(40));
freq_order  = repmat([1:10],4,1)';
for i = 1:4
    freq_order(:,i) = freq_order(randperm(10),i);
end
own_radio_count = 1;            % counter for 'current' own radio to change
own_freq_count = [1 1 1 1];     % counter for 'current' own frequency to set
other_radio_count = 1;            % counter for 'current' own radio to change
other_freq_count = [1 1 1 1];     % counter for 'current' own frequency to set

% create event report file
fid2 = fopen(Event_file_name,'w');
fprintf(fid2,'Multi-Attribute Task Battery Events\n');
fprintf(fid2,'---------- TRIAL 1: 00:00 ----------\n');
trial_no = 2;
track_string = {'Start','Stop'};
comm_string = {'Other','Own','Start','Stop'};

% create updated events.mat file
events2 = table(times, sysmon, track, comm, resman, rate);

% create XML file
tiempoReal = extractBetween(string(datetime),length(date)+2,length(char(datetime)));
fid = fopen(XML_file_name,'w');
fprintf(fid,'<!-- Multi-Attribute Task Battery Events -->\n');
fprintf(fid,'<!-- Generated on %s at %s-->\n',date, tiempoReal);
fprintf(fid,'<!-- Generated using MATB_XML.m-->\n');
fprintf(fid,'<MATB-EVENTS>\n');

% start time
fprintf(fid,'<!-- Start MATB Timer --> \n');
fprintf(fid,'<event startTime="0:00:00">\n');
fprintf(fid,'	<control>START</control>\n');
fprintf(fid,'</event>\n');

% start tasks
fprintf(fid,'<!-- Start Resource Management and System Monitoring tasks  --> \n');
fprintf(fid,'<event startTime="0:00:01">\n');
fprintf(fid,'	<sched>\n');
fprintf(fid,'      <task>RESSYS</task>\n');
fprintf(fid,'      <action>START</action>\n');
fprintf(fid,'      <update>NULL</update>\n');
fprintf(fid,'      <response>NULL</response>\n');
fprintf(fid,'   </sched> \n');
fprintf(fid,'</event>\n');

up_or_down = {'UP','DOWN'};
scale_number = {'ONE','TWO','THREE','FOUR'};
sysmon_started = 0;
radio_options = {'COM1','COM2','NAV1','NAV2'};
tracking_status = 0;
comm_status = 0;
own_comm_timer = 0;
            
for i = 1:(totalLength+1)
    
    % convert current time into HH:MM:SS string
    sec = mod(events.times(i),60);
    min = floor(events.times(i)/60);
    hr = floor(events.times(i)/3600);
    elapsedTime = sprintf('%01d:%02d:%02d',hr, min, sec);
    
    if events.sysmon(i) ~= 0    % check for sysmon events
        if events.sysmon(i) < 5         % F1-F4 gauges
            if sysmon_started == 0
                rand_up_down = randi(2);
                fprintf(fid,'<!-- System Monitoring - Turn Normally ON to OFF --> \n');
                fprintf(fid,'<event startTime="%s">\n',elapsedTime);
                fprintf(fid,'	<sysmon activity="START"> \n');     % starts sysmon task;
                fprintf(fid,'      <monitoringScaleNumber>%s</monitoringScaleNumber>\n',scale_number{events.sysmon(i)});
                fprintf(fid,'      <monitoringScaleDirection>%s</monitoringScaleDirection>\n', up_or_down{rand_up_down});   % randomizes whether given scale goes up or down
                fprintf(fid,'   </sysmon> \n');
                fprintf(fid,'</event>\n');
                sysmon_started = 1;
                
                % save data for use later
                events2.sysmon(i) = events.sysmon(i);
                fprintf(fid2,'%s -- SYSMON START\n',elapsedTime);
                fprintf(fid2,'%s -- SYSMON F%d\n',elapsedTime,events.sysmon(i));
            else
                rand_up_down = randi(2);
                fprintf(fid,'<!-- System Monitoring - Move SCALE %s %s -->\n',scale_number{events.sysmon(i)}, up_or_down{rand_up_down});
                fprintf(fid,'<event startTime="%s">\n',elapsedTime);
                fprintf(fid,'	<sysmon>\n');
                fprintf(fid,'      <monitoringScaleNumber>%s</monitoringScaleNumber>\n',scale_number{events.sysmon(i)});
                fprintf(fid,'      <monitoringScaleDirection>%s</monitoringScaleDirection>\n', up_or_down{rand_up_down});   % randomizes whether given scale goes up or down
                fprintf(fid,'   </sysmon>\n');
                fprintf(fid,'</event>\n');
                
                % save data for use later
                events2.sysmon(i) = events.sysmon(i);
                fprintf(fid2,'%s -- SYSMON F%d\n',elapsedTime,events.sysmon(i));
            end
        elseif events.sysmon(i) == 5       % F5
            if sysmon_started == 0
            	fprintf(fid,'<!-- System Monitoring - Turn Normally ON to OFF --> \n');
                fprintf(fid,'<event startTime="%s">\n',elapsedTime);
                fprintf(fid,'	<sysmon activity="START"> \n');     % starts sysmon task
                fprintf(fid,'      <monitoringLightType>GREEN</monitoringLightType>\n');
                fprintf(fid,'   </sysmon> \n');
                fprintf(fid,'</event>\n');
                sysmon_started = 1;                
                
                % save data for use later
                events2.sysmon(i) = events.sysmon(i);
                fprintf(fid2,'%s -- SYSMON START\n',elapsedTime);
                fprintf(fid2,'%s -- SYSMON F%d\n',elapsedTime,events.sysmon(i));
            else
                fprintf(fid,'<!-- System Monitoring - Turn Normally ON to OFF -->\n');
                fprintf(fid,'<event startTime="%s">\n',elapsedTime);
                fprintf(fid,'         <sysmon>\n');
                fprintf(fid,'      <monitoringLightType>GREEN</monitoringLightType>\n');
                fprintf(fid,'   </sysmon> \n');
                fprintf(fid,'</event>\n');
                
                % save data for use later
                events2.sysmon(i) = events.sysmon(i);
                fprintf(fid2,'%s -- SYSMON F%d\n',elapsedTime,events.sysmon(i));
            end
        elseif events.sysmon(i) == 6      % F6 
            if sysmon_started == 0
                fprintf(fid,'<!-- System Monitoring - Turn Normally OFF to ON -->\n');
                fprintf(fid,'<event startTime="%s">\n',elapsedTime);
                fprintf(fid,'	<sysmon activity="START"> \n');     % starts sysmon task
                fprintf(fid,'      <monitoringLightType>RED</monitoringLightType>\n');
                fprintf(fid,'   </sysmon> \n');
                fprintf(fid,'</event>\n');
                sysmon_started = 1;
                
                % save data for use later
                events2.sysmon(i) = events.sysmon(i);
                fprintf(fid2,'%s -- SYSMON START\n',elapsedTime);
                fprintf(fid2,'%s -- SYSMON F%d\n',elapsedTime,events.sysmon(i));
            else
                fprintf(fid,'<!-- System Monitoring - Turn Normally OFF to ON -->\n');
                fprintf(fid,'<event startTime="%s">\n',elapsedTime);
                fprintf(fid,'         <sysmon>\n');
                fprintf(fid,'      <monitoringLightType>RED</monitoringLightType>\n');
                fprintf(fid,'   </sysmon> \n');
                fprintf(fid,'</event>\n');
                
                % save data for use later
                events2.sysmon(i) = events.sysmon(i);
                fprintf(fid2,'%s -- SYSMON F%d\n',elapsedTime,events.sysmon(i));
            end
        end
    end

    if events.track(i) ~= 0     % check for track events
        if events.track(i) == 1 && tracking_status == 0         % switch to easy manual if off
            fprintf(fid,'<!-- Sched task: TRACK START -->\n');
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<sched>\n');
            fprintf(fid,'      <task>TRACK</task>\n');
            fprintf(fid,'      <action>MANUAL</action>\n');
            fprintf(fid,'      <update>HIGH</update>\n');
            fprintf(fid,'      <response>MEDIUM</response>\n');
            fprintf(fid,'   </sched> \n');
            fprintf(fid,'</event>\n');
            tracking_status = 1;
                
            % save data for use later
            events2.track(i) = events.track(i);        
            fprintf(fid2,'%s -- TRACK %s\n',elapsedTime,track_string{events.track(i)});
            
        elseif events.track(i) == 2 && tracking_status ~= 0     % switch to auto if manual
            fprintf(fid,'<!-- Sched task: TRACK AUTO --> \n');
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<sched >\n');
            fprintf(fid,'      <task>TRACK</task>\n');
            fprintf(fid,'      <action>AUTO</action>\n');
            fprintf(fid,'      <update>NULL</update>\n');
            fprintf(fid,'      <response>NULL</response>\n');
            fprintf(fid,'   </sched> \n');
            fprintf(fid,'</event>\n');
            tracking_status = 0;
                
            % save data for use later
            events2.track(i) = events.track(i);           
            fprintf(fid2,'%s -- TRACK %s\n',elapsedTime,track_string{events.track(i)});
        end
    end
    
    if events.comm(i) ~= 0      % check for comm events
        if events.comm(i) == 1    % OTHER comm event 
            radio_num = radio_order(other_radio_count);
            radio_string = radio_options{radio_num};
            freq_num = freq_order(other_freq_count(radio_num), radio_num);
            freq_string = sprintf("%0.3f",other{freq_num,radio_num});
            fprintf(fid,'<!-- Other ship radio change, no action by subject --> \n');
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<comm>\n');
            fprintf(fid,'      <ship>OTHER</ship>\n');
            fprintf(fid,'      <radio>%s</radio>\n',radio_string);
            fprintf(fid,'      <freq>%s</freq>\n',freq_string);
            fprintf(fid,'   </comm> \n');
            fprintf(fid,'</event>\n');
            
            other_radio_count = other_radio_count + 1;  % randomizes radio order
            if other_radio_count > 40                   % ensures we don't run out :-)
                other_radio_count = 1;
            end
            other_freq_count(radio_num) = other_freq_count(radio_num)+1;    % randomizes radio frequency
            if other_freq_count(radio_num) > 10       % ensures we don't run out :-)
                other_freq_count(radio_num) = 1;
            end
            
            % save data for use later
            events2.comm(i) = events.comm(i);   
            fprintf(fid2,'%s -- COMM %s\n',elapsedTime,comm_string{events.comm(i)});

        elseif events.comm(i) == 2     % OWN comm event
            radio_num = radio_order(own_radio_count);
            radio_string = radio_options{radio_num};
            freq_num = freq_order(own_freq_count(radio_num), radio_num);
            freq_string = sprintf("%0.3f",own{freq_num,radio_num});

            
            fprintf(fid,'<!-- Communication - OWN ship %s -->\n',radio_string);
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<comm>\n');
            fprintf(fid,'      <ship>OWN</ship>\n');
            fprintf(fid,'      <radio>%s</radio>\n',radio_string);
            fprintf(fid,'      <freq>%s</freq>\n',freq_string);
            fprintf(fid,'   </comm> \n');
            fprintf(fid,'</event>\n');
            
            
            own_radio_count = own_radio_count + 1;  % randomizes radio order
            if own_radio_count > 40                  % ensures we don't run out :-)
                own_radio_count = 1;
            end
            own_freq_count(radio_num) = own_freq_count(radio_num)+1;    % randomizes radio frequency
            if own_freq_count(radio_num) > 10       % ensures we don't run out :-)
                own_freq_count(radio_num) = 1;
            end
            
            % save data for use later
            events2.comm(i) = events.comm(i);
            events2.comm_radio{i} = radio_string;
            events2.comm_freq{i} = freq_string;
            fprintf(fid2,'%s -- COMM %s\n',elapsedTime,comm_string{events.comm(i)});

        elseif events.comm(i) == 3 && comm_status == 0                 % start comm event session if not already in one
            fprintf(fid,'<!-- Sched task: COMM START --> \n');
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<sched>\n');
            fprintf(fid,'      <task>COMM</task>\n');
            fprintf(fid,'      <action>START</action>\n');
            fprintf(fid,'      <update>NULL</update>\n');
            fprintf(fid,'      <response>NULL</response>\n');
            fprintf(fid,'   </sched> \n');
            fprintf(fid,'</event>\n');
            comm_status = 1;
            
            % save data for use later
            events2.comm(i) = events.comm(i);
            fprintf(fid2,'%s -- COMM %s\n',elapsedTime,comm_string{events.comm(i)});

        elseif events.comm(i) == 4 && comm_status == 1                   % stop comm event session if already in one
            fprintf(fid,'<!-- Sched task: COMM STOP --> \n');
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<sched>\n');
            fprintf(fid,'      <task>COMM</task>\n');
            fprintf(fid,'      <action>STOP</action>\n');
            fprintf(fid,'      <update>NULL</update>\n');
            fprintf(fid,'      <response>NULL</response>\n');
            fprintf(fid,'   </sched> \n');
            fprintf(fid,'</event>\n');
            comm_status = 0;
            
            
            % save data for use later
            events2.comm(i) = events.comm(i);
            fprintf(fid2,'%s -- COMM %s\n',elapsedTime,comm_string{events.comm(i)});

        end
            
    end
    
    if events.resman(i) ~= 0    % check for resman events
        if events.resman(i) <= 8    % failure events
            fprintf(fid,'<!-- Sched task: RESMAN fail pump %d  -->\n',events.resman(i)); 
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<resman>\n');
            fprintf(fid,'      <fail>P%d</fail>\n',events.resman(i)); 
            fprintf(fid,'   </resman>\n');
            fprintf(fid,'</event>\n');
            
            % save data for use later
            events2.resman(i) = events.resman(i);
            fprintf(fid2,'%s -- RESMAN Fail P%d\n',elapsedTime,events.resman(i));

        elseif events.resman(i) <= 16   % fix events
            fprintf(fid,'<!-- Sched task: RESMAN fix pump %d  -->\n',events.resman(i)-8);
            fprintf(fid,'<event startTime="%s">\n',elapsedTime);
            fprintf(fid,'	<resman>\n');
            fprintf(fid,'      <fix>P%d</fix>\n',(events.resman(i)-8)  );
            fprintf(fid,'  </resman> \n');
            fprintf(fid,'</event>\n');
            
            % save data for use later
            events2.resman(i) = events.resman(i);
            fprintf(fid2,'%s -- RESMAN Fix P%d\n',elapsedTime,events.resman(i)-8);

        end
    end
    
    if events.rate(i) == 1      % check for rate events
        fprintf(fid,'<!-- Workload Rating -->\n'); 
        fprintf(fid,'<event startTime="%s">\n',elapsedTime);
        fprintf(fid,'	<rate>START</rate> \n');
        fprintf(fid,'</event>\n');
        
        % save data for use later
        events2.rate(i) = events.rate(i);
        fprintf(fid2,'---------- TRIAL %d: %s ----------\n',trial_no,elapsedTime);
        trial_no = trial_no+1;
    end
end

if comm_status == 1                     % Close any open comm sessions
    fprintf(fid,'<!-- Sched task: COMM STOP --> \n');
    fprintf(fid,'<event startTime="%s">\n',elapsedTime);
    fprintf(fid,'	<sched>\n');
    fprintf(fid,'      <task>COMM</task>\n');
    fprintf(fid,'      <action>STOP</action>\n');
    fprintf(fid,'      <update>NULL</update>\n');
    fprintf(fid,'      <response>NULL</response>\n');
    fprintf(fid,'   </sched> \n');
    fprintf(fid,'</event>\n');
    comm_status = 0;
    
    % save data for use later
    fprintf(fid2,'%s -- COMM %s\n',elapsedTime,comm_string{4});
end

% end experiment
fprintf(fid,'<!-- Stop MATB Timer and end experiment -->\n');
fprintf(fid,'<event startTime="%s">\n',elapsedTime);
fprintf(fid,'	<control>END</control>\n');
fprintf(fid,'</event>\n');
fprintf(fid,'</MATB-EVENTS>\n');

% save events matrix
save(event_mat_name, 'events2');

fclose(fid);
fclose(fid2);


% get time to complete
ttc = toc;

%% Function!
function randDelay = randomDelay(event_category,event_time,existing_delay,rand_range,rand_start)
    randDelay = randi(rand_range)+rand_start;
    counter = 0;
    
    % ensures we don't dump an event on top of another
    % that we don't loop forever
    % and that we don't have events outside of the file length
    while (event_time+1+existing_delay+randDelay) <= length(event_category) && ...
            (event_category(event_time+1+existing_delay+randDelay) ~= 0) && (counter < rand_range)
        randDelay = randi(10)+4; % random rand_start+1-->rand_start+rand_range
        counter = counter+1;
    end
    
    if counter >= rand_range
        warning('Counter limit reached, likely event overlay.')
    end
    
    if (event_time+1+existing_delay+randDelay) > length(event_category)
        warning('Task duration hit, event omitted.')
    end
end