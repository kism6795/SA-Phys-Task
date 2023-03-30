function sa_score = SA_Scorer(trial_num,subject_folder,response_file, date_time)
%% MATB SA Quiz Scorer
%{ 
    Written by Kieran J Smith, kieran.smith@colorado.edu on August 23, 2022 
    as part of a project in conjunction with Draper Labs to score
    objective freeze-probe quizzes designed to assess SA in a modified
    MATB-II task.
%}

data_folder = 'SubjectData';
% date_time = '08241241';
% subject_folder = 'Pilot_08-24_jk';
% response_file = 'SA Assessment_August 26, 2022_13.48.xlsx';
flow_rates = [1000, 500, 800, 400, 500, 500, 700, 800, 800];

%% Import generated XML file
load('events.mat');
events = events2; clear events2

%% Import MATB Data
[rate_data, sysmon_data, track_data, comm_data, resman_data] = getMATBdata(subject_folder, data_folder);

%% Import Questionnaire Answers - takes a few seconds
%{
1 = yes
2 = no
%}
response_data = readtable(fullfile('..\',data_folder,subject_folder,response_file));
if exist('response_data.RecipientLastName','var')
    response_data = removevars(response_data,{'RecipientLastName','RecipientFirstName','RecipientEmail','ExternalReference'});
end

%% Score RESMAN Answers
sa_scores = zeros(1,3);
sa_scores = scoreRESMAN(response_data, rate_data, resman_data, sa_scores, flow_rates, trial_num);
sa_scores = scoreSYSMON(response_data, rate_data, sysmon_data, sa_scores, events, trial_num);
sa_scores = scoreTRACK(response_data, rate_data, track_data, sa_scores, events, trial_num);
sa_scores = scoreCOMM(response_data, rate_data, comm_data, sa_scores, events, trial_num);


%% pull out trial of interest, sorry this is so inefficient
sa_score = sa_scores(trial_num,3);


end