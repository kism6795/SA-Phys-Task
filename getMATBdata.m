function [rate_data, sysmon_data, track_data, comm_data, resman_data, matb_data] = getMATBdata(subject_folder, data_folder)
%% Find MATB File
MATBregex = strcat(data_path,'\','MATB_*.txt'); % 2022 for all original subjects
MATBfilename = dir(MATBregex);
MATBinfo = strcat(data_path,'\',MATBfilename.name);
date_time = extractBetween(MATBfilename.name,'MATB_','.txt');
date_time = date_time{1};

%% RATE - get rate times
rate_file = strcat('RATE_',date_time,'.txt');
fid = fopen(fullfile('..\',data_folder,subject_folder,rate_file));

tline = fgetl(fid);
count = 1;
while ischar(tline)
    if tline(1) ~= '#'
        % get time
        temp_datetime = datetime(extractBefore(tline,' '));
        rate_times(count,:) = [temp_datetime.Minute, temp_datetime.Second];
        
        % get duration
        temp_datetime = datetime(strtrim(tline(11:22)), 'InputFormat', 'mm:ss.S');
        rate_durations(count,:) = [temp_datetime.Minute, temp_datetime.Second];
        
        % get scores 
        temp_string = regexprep(strtrim(tline(22:end)),' +',' ');
        temp_array = textscan(temp_string, '%f', 'Delimiter',' ' );
        rate_scores(count,:) = temp_array{1};
        
        count = count+1;
    end
    tline = fgetl(fid);
end

fclose(fid);
if ~exist('rate_times','var') 
    rate_times = [];
    rate_durations = [];
    rate_scores = [];
end
rate_data = table(rate_times, rate_durations, rate_scores);
clear rate_times rate_durations rate_scores
rate_data.Properties.VariableNames = {'times','durations','scores'};

%% RESMAN - get resman data and event times
resman_file = strcat('RMAN_',date_time,'.txt');
fid = fopen(fullfile('..\',data_folder,subject_folder,resman_file));

tline = fgetl(fid);
count = 1;
while ischar(tline)
    if tline(1) ~= '#'          % only data lines
        if tline(40) == 'N'     % only event-based writings
            % extract time of event
            tline = strtrim(tline);
            temp_string = extractBefore(tline,' ');
            tline = extractAfter(tline,temp_string);
            temp_datetime = datetime(temp_string);
            pump_times(count,:) = [temp_datetime.Minute, temp_datetime.Second];

            % extract pump number
            tline = strtrim(tline);
            temp_string = extractBefore(tline,' ');
            pumps(count) = str2double(temp_string);
            tline = extractAfter(tline,temp_string);
            
            % extract pump action
            tline = strtrim(tline);        
            temp_string = extractBefore(tline,' ');
            actions{count} = temp_string;
            tline = extractAfter(tline,temp_string);

            % extract fuel levels
            tline = strtrim(tline);
            tline = strtrim(tline(2:end));        
            tline = regexprep(tline,' +',' ');      % turns n spaces into one
            temp_array = textscan(tline, '%f', 'Delimiter',' ' );   % turns text into an array :--)
            fuel_levels(count,:) = temp_array{1}';
            count = count+1;
        end        
    end
    tline = fgetl(fid);
end

fclose(fid);

if ~exist('pump_times','var') 
    pump_times= [];
    pumps= [];
    actions= {};
    fuel_levels= [];
end

resman_data = table(pump_times, pumps', actions', fuel_levels);
clear pump_times pumps actions fuel_levels
resman_data.Properties.VariableNames = {'times','pumps','actions','fuel_levels'};

%% COMM - get comm data and event times
comm_file = strcat('COMM_',date_time,'.txt');
fid = fopen(fullfile('..\',data_folder,subject_folder,comm_file));



tline = fgetl(fid);
count = 1;
while ischar(tline)
    if tline(1) ~= '#'          % only data lines
        % extract time of event
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        tline = extractAfter(tline,temp_string);
        temp_datetime = datetime(temp_string);
       	comm_times(count,:) = [temp_datetime.Minute, temp_datetime.Second];

        % extract event number
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        event_nums(count) = str2double(temp_string);
        tline = extractAfter(tline,temp_string);

        % extract ship
        tline = strtrim(tline);        
        temp_string = extractBefore(tline,' ');
        cmd_ships{count} = temp_string;
        tline = extractAfter(tline,temp_string);

        % extract radio commanded
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        cmd_radios{count} = temp_string;
        tline = extractAfter(tline,temp_string);
        
        % extract frequency commanded
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        cmd_frequencies(count) = str2double(temp_string);
        tline = extractAfter(tline,temp_string);
        
        % extract radio response
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        rsp_radios{count} = temp_string;
        tline = extractAfter(tline,temp_string);
        
        % extract frequency response
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        rsp_frequencies(count) = str2double(temp_string);
        tline = extractAfter(tline,temp_string);

        % extract scores
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        rsp_scores(count,1) = strcmp(temp_string,'True');
        tline = extractAfter(tline,temp_string);
        temp_string = strtrim(tline);
        rsp_scores(count,2) = strcmp(temp_string,'True');
        
        count = count+1;
    end
    tline = fgetl(fid);
end
if ~exist('comm_times','var') 
    comm_times = [];
    event_nums = [];
    cmd_ships = {};
    cmd_radios = {};
    cmd_frequencies = [];
    rsp_radios = {};
    rsp_frequencies = {};
    rsp_scores = [];
end

fclose(fid);
comm_data = table(comm_times, event_nums', cmd_ships', cmd_radios', cmd_frequencies', rsp_radios', rsp_frequencies', rsp_scores);
clear comm_times cmd_ships cmd_radios cmd_frequencies rsp_radios rsp_frequencies rsp_scores
comm_data.Properties.VariableNames = {'times','event_num','ship_exp','radio_exp','freq_exp','radio_act','freq_act','scores'};

%% SYSMON - get sysmon data and event times
sysm_file = strcat('SYSM_',date_time,'.txt');
fid = fopen(fullfile('..\',data_folder,subject_folder,sysm_file));

tline = fgetl(fid);
count = 1;
while ischar(tline)
    if tline(1) ~= '#'          % only data lines  
        % extract reaction time
        sysm_RTs(count) = str2double(strtrim(tline(12:22)));
        
        % extract display number
        temp_string = strtrim(tline(28:37));
        switch temp_string
            case 'ONE'
                sysm_Fnum(count) = 1;
            case 'TWO'
                sysm_Fnum(count) = 2;
            case 'THREE'
                sysm_Fnum(count) = 3;
            case 'FOUR'
                sysm_Fnum(count) = 4;
            case 'GREEN'
                sysm_Fnum(count) = 5;
            case 'RED'
                sysm_Fnum(count) = 6;
        end     

        % extract time of event
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        tline = extractAfter(tline,temp_string);
        temp_datetime = datetime(temp_string);
       	sysm_times(count,:) = [temp_datetime.Minute, temp_datetime.Second];
        count = count+1;
    end
    tline = fgetl(fid);
end

if ~exist('sysm_times','var') 
    sysm_times = [];
    sysm_Fnum = [];
    sysm_RTs = [];
end

sysmon_data = table(sysm_times, sysm_Fnum', sysm_RTs');
clear sysm_times sysm_Fnum sysm_RTs
sysmon_data.Properties.VariableNames = {'times','F_num','RTs'};
fclose(fid);

%% TRACK - get track data and event times
trck_file = strcat('TRCK_',date_time,'.txt');
fid = fopen(fullfile('..\',data_folder,subject_folder,trck_file));

tline = fgetl(fid);
count = 1;
while ischar(tline)
    if tline(1) ~= '#'          % only data lines  
        % extract time of event
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        temp_datetime = datetime(temp_string);
       	track_times(count,:) = [temp_datetime.Minute, temp_datetime.Second];
        
        % extract SS
        temp_string = strtrim(tline(35:55));
        track_SS(count) = str2double(temp_string);
        
        % extract RMSD
        temp_string = strtrim(tline(55:62));
        track_RMSD(count) = str2double(temp_string);
        
        count = count+1;
    end
    tline = fgetl(fid);
end
fclose(fid);

if ~exist('track_times','var') 
    track_times = [];
    track_SS = [];
    track_RMSD = [];
end

track_data = table(track_times, track_SS', track_RMSD');
clear track_times track_SS track_RMSD
track_data.Properties.VariableNames = {'times','SS','RMSD'};

%% MATB - get matb data, event times, and event numbers
trck_file = strcat('MATB_',date_time,'.txt');
fid = fopen(fullfile('..\',data_folder,subject_folder,trck_file));

tline = fgetl(fid);
count = 1;
while ischar(tline)
    if tline(1) ~= '#' && tline(1) ~= ' ' % only data lines  
        % extract time of event
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        temp_datetime = datetime(temp_string);
       	matb_times(count,:) = [temp_datetime.Minute, temp_datetime.Second];
        tline = extractAfter(tline,temp_string);
                
        % extract event number
        tline = strtrim(tline);
        temp_string = extractBefore(tline,' ');
        event_nums(count) = str2double(temp_string);
        tline = extractAfter(tline,temp_string);
        
        % extract text
        event_text{count} = tline;
        
        count = count+1;
    end
    tline = fgetl(fid);
end
fclose(fid);

if ~exist('matb_times','var') 
    matb_times = [];
    event_nums = [];
    event_text = [];
end

matb_data = table(matb_times, event_nums', event_text');
clear matb_times event_nums event_text
matb_data.Properties.VariableNames = {'times','event_num','event_detail'};


end