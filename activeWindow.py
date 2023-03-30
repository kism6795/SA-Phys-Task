# -*- coding: utf-8 -*-
"""
Created on Fri Aug  5 16:24:55 2022

@author: Kieran J. Smith

Designed for use in a MATB task so that time spent clicked on MATB window can
be calculated and used to synchronize events to physiological signals.
SA Assessment: https://cuboulder.qualtrics.com/jfe/form/SV_5auI3KlgInYckL4
Practice: https://cuboulder.qualtrics.com/jfe/form/SV_czEvW2hwv3BqD30


UPDATES TO MAKE:
1. Include Trial Start Trigger on Trial 1
2. Replace Active Window stream with a trial number stream (rename it too)
3. 
"""

#%% General Imports
from functools import total_ordering
import time
from datetime import datetime
import sys
# for active window measurements
from win32.win32gui import GetWindowText, GetForegroundWindow, SetForegroundWindow, FindWindow, GetActiveWindow 
# LSL Stream
from pylsl import StreamInfo, StreamOutlet
# File Management
import os
import glob
import shutil
# Running Matlab Code
import matlab.engine
# Qualtrics Imports
import requests
import zipfile
import json
import io
import base64
import http.client
# Pop-up Messages
import tkinter as tk
from tkinter import ttk
import win32com.client

# Enables SetForegroundWindow Function according to StackOverflow
# https://stackoverflow.com/questions/14295337/win32gui-setactivewindow-error-the-specified-procedure-could-not-be-found
shell = win32com.client.Dispatch("WScript.Shell")
shell.SendKeys('%')

#%% Qualtrics Setup ##
# Set user/survey access Parameters
apiToken = "T3KYoUDyjNTUh3pEI3RjQRRaauXsLbthDofthdjt"
surveyId = "SV_5auI3KlgInYckL4"
fileFormat = "csv"
dataCenter = 'yul1'
requestCheckProgress = 0
progressStatus = "in progress"
baseUrl = "https://{0}.qualtrics.com/API/v3/responseexports/".format(dataCenter)
headers = {
    "content-type": "application/json",
    "x-api-token": apiToken,
    }

#%% Data Management Setup ##
#1 set date/folder names
cwd = os.getcwd()
subj_num = '002'        # format
test_date = '0923'      # format [mmdd]
subj_folder = "Subject-{0}-{1}".format(subj_num, test_date);
code_window = GetWindowText(GetForegroundWindow()); # get the name of this window
#2 set MATB location
MATB_path = 'C:\\MATB\\Data'
#3 get last file name if other files exist
file_type = r'\*txt'
files = glob.glob(MATB_path + file_type)
old_files = '';
if len(files) >= 1:
    max_file = max(files, key=os.path.getctime)
    old_files = max_file[18:30];
file_end = old_files;
#4 create subject data path
data_path = "C:\\Users\\ander\\Documents\\SmithSA\\SubjectData"
data_path = data_path + '\\' + subj_folder
if not os.path.exists(data_path):
    os.mkdir(data_path);

#%% MATLAB Engine Setup ##       
eng = matlab.engine.start_matlab(); # start matlab engine
motivation = eng.MATB_XML(subj_num, test_date)    # run XML-generator code
print("XML Files Generated!");

#%% LSL Stream Setup ##
stream_info = StreamInfo(name = 'ActiveWindow', type = 'MATB', channel_count= 1, nominal_srate=100, channel_format = 'string');
stream_outlet = StreamOutlet(stream_info);    # create lsl stream
stream_info1 = StreamInfo(name = 'Trigger', type = 'MATB', channel_count= 1, nominal_srate=100, channel_format = 'int32');
stream_outlet1 = StreamOutlet(stream_info1);    # create lsl stream

#%% TKinter Popup Setup
NORM_FONT= ("Verdana", 10);
total_earning = 0;
msg = "Hello. Please wait while we calculate your scores.";

#%% Create Scores File
score_file = "Scores-{0}-{1}.txt".format(subj_num, test_date);
f2 = open(score_file,'w');

#%% Active Window Monitor Setup ##
window_int = 0;                                     # stores last active window for sequencing logic
start_time = datetime.now();                        # get time program is run
active_window = code_window;                        # set active window to current
timer = time.time();                                # start timer
timeout = 7200;                                     # timeout time (in seconds)
trial_length = 105;                                 # minimum trial length in seconds

while 1:
    active_window = GetWindowText(GetForegroundWindow());
    if active_window != code_window:                # start the run if we leave Code Window
        break;
    if time.time() - timer > timeout:               # quit the run if we timeout here
        sys.exit();

#%% create and open new file at start time, once python window is minimized
file_name = str("ActiveWindow_%s-%d_%02d-%02d.txt" % (start_time.month, start_time.day, start_time.hour, start_time.minute))
f = open(file_name,'w');
print('Active Window File Created');
timer = time.time();                                # restart timer 
last_wrs = time.time();                             # start WRS timer

trial_count = 1;                # trial counter
trial_started = 0;              # trial start bool

while 1:    
    if active_window != GetWindowText(GetForegroundWindow()):   # if the window changes
        now = datetime.now()
        f.write("%02d:%02d:%02d.%d —— " % (now.hour, now.minute, now.second, now.microsecond));
        try:
            f.write(GetWindowText(GetForegroundWindow()));
        except:
            print("Could not write window text.")
            f.write("Could not write window text.")
        f.write('\n')
        active_window = GetWindowText(GetForegroundWindow());   # set new active window
        
        if (active_window[0:32] == "Multi Attribute Task  Battery II") & (trial_started == 0):
            
            #%% Trial 1 Popup
            info_win = tk.Tk();
            info_win.geometry("500x270+1000+400");
            titlemsg = "Trial {0} Scores:".format(trial_count);
            info_win.wm_title("Welcome!");
            if (motivation[0][0] == 0):
                wlcm = "The first trial will have normal SA bonuses ($0.10/question).";
            elif (motivation[0][0] == 1):
                wlcm = "The first trial will have double SA bonuses ($0.20/question).";
            label = ttk.Label(info_win, text=wlcm, font=NORM_FONT);
            label.pack(side="top", fill="x", pady=10);
            info_win.update();
            info_winhandle = FindWindow(None, "Welcome!")
            print("Popup Window Handle: {0}".format(info_winhandle));
            SetForegroundWindow(info_winhandle);
            B2 = ttk.Button(info_win, text="Okay", command = info_win.destroy);
            B2.pack();
            info_win.mainloop();
            del info_win
            
            #%% first time MATB window appears only (once MATB has started running)
            print('Trial Started!');

            #%% get MATB data file names once they are created
            file_type = r'\*txt'
            while (file_end == old_files) & (time.time() - timer < timeout):
                files = glob.glob(MATB_path + file_type)
                max_file = max(files, key=os.path.getctime)
                file_end = max_file[18:30];
            rate_file = "RATE_" + file_end;
            matb_file = "MATB_" + file_end;
            trck_file = "TRCK_" + file_end;
            rman_file = "RMAN_" + file_end;
            sysm_file = "SYSM_" + file_end;
            comm_file = "COMM_" + file_end;
            print('MATB File Names Generated');

            #%% start trial
            trial_started = 1;
            
        if active_window[0:40] == 'Situation Awareness Objective Assessment':
            window_int = 1;         
            print('SA Assessment: Trial {0}'.format(trial_count));
            stream_outlet1.push_sample(x = [2]);   # ping fNIRS when SA Assessment is started

        if (active_window[1:22] == 'Workload Rating Scale') & (window_int == 1):
            window_int = 2;       
            print('NASA TLX: Trial {0}'.format(trial_count));
            stream_outlet1.push_sample(x = [3]);   # ping fNIRS when WRS is started

        # if MATB trial restarts after SA and WRS and at least 2 minutes
        if (active_window[0:32] == "Multi Attribute Task  Battery II") & (window_int == 2) & (time.time() - last_wrs > trial_length):
            
            #%% Pause Trial with Popup
            popup = tk.Tk();
            popup.geometry("500x270+1000+400");
            titlemsg = "Trial {0} Scores:".format(trial_count);
            popup.wm_title("Scores:");
            label = ttk.Label(popup, text=msg, font=NORM_FONT);
            label.pack(side="top", fill="x", pady=10);
            popup.update();
            popup_handle = FindWindow(None, "Scores:")
            print("Popup Window Handle: {0}".format(popup_handle));
            SetForegroundWindow(popup_handle);
            
            #%% post status to commant prompt
            print('Trial {0} Complete,  Downloading  MATB Data.'.format(trial_count));

            #%% enters this if WRS comes after an SA Assessment & if it's been 2 minutes since the last time we came here
            window_int = 2;
            last_wrs = time.time();  

            #%% copy MATB Data from files
            shutil.copy(MATB_path + "\\" + rate_file, data_path + "\\" + rate_file);
            shutil.copy(MATB_path + "\\" + matb_file, data_path + "\\" + matb_file);
            shutil.copy(MATB_path + "\\" + trck_file, data_path + "\\" + trck_file);
            shutil.copy(MATB_path + "\\" + rman_file, data_path + "\\" + rman_file);
            shutil.copy(MATB_path + "\\" + sysm_file, data_path + "\\" + sysm_file);
            shutil.copy(MATB_path + "\\" + comm_file, data_path + "\\" + comm_file);
            print("MATB Files Copied");
            
            #%% run MATB Scorer MATLAB code:
            matb_scores = eng.MATB_Scorer(trial_count,subj_folder, file_end[0:8]);
            print("MATB Score:");
            print(matb_scores);

            #%% download SA data 
            zip_timer = time.time();
            response_file = "SA Assessment.csv"
            download_failed = 1;
            # loops through data download processbecause it typically works on the second try (no clue why)
            while(time.time()-zip_timer < 15): 
                # Step 1: Creating Data Export
                downloadRequestUrl = baseUrl
                downloadRequestPayload = '{"format":"' + fileFormat + '","surveyId":"' + surveyId + '"}'
                downloadRequestResponse = requests.request("POST", downloadRequestUrl, data=downloadRequestPayload, headers=headers)
                progressId = downloadRequestResponse.json()["result"]["id"]
                # Step 2: Checking on Data Export Progress and waiting until export is ready
                while (requestCheckProgress < 100) & (progressStatus != "complete"):
                    requestCheckUrl = baseUrl + progressId
                    requestCheckResponse = requests.request("GET", requestCheckUrl, headers=headers)
                    requestCheckProgress = requestCheckResponse.json()["result"]["percentComplete"]
                    print("Download is " + str(requestCheckProgress) + " complete")
                # Step 3: Downloading file
                requestDownloadUrl = baseUrl + progressId + '/file'
                requestDownload = requests.request("GET", requestDownloadUrl, headers=headers, stream=True)
                # Step 4: Unzipping the file
                aa = str(requestDownload);
                if aa[11:14] == '200':
                    zipfile.ZipFile(io.BytesIO(requestDownload.content)).extractall(data_path);
                    print('Qualtrics Download Complete')
                    download_failed = 0;
                    break;
                else:
                    print('Qualtrics Download  Failure')
            
            if download_failed:
                print('Download Failed, giving full-credit for SA.')

            response_file = "SA Assessment.csv"

            #%% run SA Scorer MATLAB code:
            sa_scores = eng.SA_Scorer(trial_count,subj_folder, response_file, file_end[0:8]);
            sa_scores = sa_scores[0];
            print("SA Score:");
            print(sa_scores);
            sa_score = sum(sa_scores);
            print(sa_score);

            #%% display scores to participant
            matb_weight = 0.03; # calibrate this
            if (motivation[trial_count-1][0] == 0):
                sa_weight = 0.1;
            elif (motivation[trial_count-1][0] == 1):
                sa_weight = 0.2;

            matb_earning = matb_scores*matb_weight;
            sa_earning = sa_score*sa_weight;
            total_earning += (sa_earning - matb_earning);

            if (trial_count+1 <= len(motivation)):
                if (motivation[trial_count][0] == 0):
                    sa_weight = 0.1;
                    msg = "MATB Score: -{0:.1f} ...... MATB Compensation: -${1:.2f}\nSA Score:    {2:.1f} ...... SA Compensation:    ${3:.2f}\n\nTotal Compensation: ${4:.2f}\nThe next trial will have normal SA bonuses ($0.10/question).".format(matb_scores, matb_earning, sa_score, sa_earning, total_earning);
                elif (motivation[trial_count][0] == 1):
                    sa_weight = 0.2;
                    msg = "MATB Score: -{0:.1f} ...... MATB Compensation: -${1:.2f}\nSA Score:    {2:.1f} ...... SA Compensation:    ${3:.2f}\n\nTotal Compensation: ${4:.2f}\nThe next trial will DOUBLE SA bonuses ($0.20/question).".format(matb_scores, matb_earning, sa_score, sa_earning, total_earning);
            elif (trial_count == len(motivation)):
                msg = "MATB Score: -{0:.1f} ...... MATB Compensation: -${1:.2f}\nSA Score:    {2:.1f} ...... SA Compensation:    ${3:.2f}\n\nTotal Compensation: ${4:.2f}\nTesting Complete!".format(matb_scores, matb_earning, sa_score, sa_earning, total_earning);
            label.pack_forget();
            
            stream_outlet1.push_sample(x = [4]);   # ping fNIRS when baseline starts
            
            # 30-second pause/return to baseline
            time.sleep(30);

            label2 = ttk.Label(popup, text=msg, font=NORM_FONT);
            label2.pack(side="top", fill="x", pady=10);
            B1 = ttk.Button(popup, text="Okay", command = popup.destroy);
            B1.pack();
            SetForegroundWindow(popup_handle);
            popup.mainloop();
            del popup

            #%% Begin Next Trial
            stream_outlet1.push_sample(x = [1]);   # ping fNIRS when trial starts
            print("Trial {0} Starting!".format(trial_count));

            #%% Save Score Data
            f2.write("Trial {0} Scores:\n".format(trial_count));
            f2.write("SA Scores: {0}, {1}, {2}; Total: {3}\n".format(sa_scores[0], sa_scores[1], sa_scores[2], sa_score));
            f2.write("MB Score: {0}\n".format(matb_scores));
            f2.write("Total Compensation: ${0:.2f}\n".format(total_earning));

            print("Trial {0} Total Compensation: {1:.2f}".format(trial_count, total_earning));
            print("Active Window Handle: {0}".format(GetActiveWindow()));
            trial_count = trial_count + 1; # update trial number

        
        stream_outlet.push_sample(x = [active_window[0:40]]);   # ping lsl stream with window name
        stream_outlet1.push_sample(x = [9]);   # ping fNIRS when window changes
        
    if active_window == code_window:                        # end the run if we return to Spyder
        f.close()
        f2.close()
        break;
    if time.time() - timer > timeout:                       # end the run if we run overtime
        f.close()
        f2.close()
        break;
        
        
stream_outlet.__del__()        # close lsl stream

#%% move active window text file to 
shutil.copy(cwd + "\\" + file_name, data_path + "\\" + file_name);
shutil.copy(cwd + "\\" + score_file, data_path + "\\" + score_file);

