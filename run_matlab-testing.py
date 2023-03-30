# -*- coding: utf-8 -*-
"""
Created on Mon Sep 12 13:13:56 2022

@author: kiera
"""

# Pop-up Messages
import tkinter as tk
from tkinter import ttk
import time

NORM_FONT= ("Verdana", 10)

msg = "Hello. Please wait while we calculate your scores.";
popup = tk.Tk();
popup.geometry("750x270+1000+400");
titlemsg = "Trial {0} Scores:".format(1);
popup.wm_title("Scores:");
label1 = ttk.Label(popup, text=msg, font=NORM_FONT);
label1.pack(side="top", fill="x", pady=10);
popup.update();

time.sleep(5)

msg = "MATB Score: {0} ...... MATB Compensation: ${1}\nSA Score:     {2} ........ SA Compensation:     ${3}\n\n ................Total Compensation: ${4}".format(10, 11, 5, 9, 5);
print(msg)
label1.pack_forget();
label2 = ttk.Label(popup, text=msg, font=NORM_FONT);
label2.pack(side="top", fill="x", pady=10);
B1 = ttk.Button(popup, text="Okay", command = popup.destroy);
B1.pack();
popup.mainloop();
