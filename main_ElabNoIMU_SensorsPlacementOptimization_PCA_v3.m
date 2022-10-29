%% Luigi Raiano, v3, 02-04-2020
%% NOTE
% Questo script è basato sulla procedura descritta nel documento
% Report_Breathing_PCA_2020-03-31_v1.pptx e si basa sulla call
% Domenico-Carlo-Joshua del 31-03-2020

% Da notare che i dati salvati nei campi raw_seg sono in realtà già
% filtrati bp 0.05-2 Hz (i dati di partenza lo erano, non è un errore nel
% loading!)
%%
clear all; close all; clc;
addpath('functions_new');
addpath('FastICA_25');
%% choose data (struct in a mat file)
disp('Choose the mat file containing the struct in which are acontained the data of alla subjects');
[file,path] = uigetfile('*.mat');

% load file
load([path,file]);
disp('data loaded');

n_subjs = length(subjs);

srate = 250;
%% 1 - Band Pass Filtering
% filter only segmented data
l_freq = 0.05; % Hz
h_freq = 2; % Hz
flt_ord = 2;

subjs_tmp = [];
subjs_tmp = BandPass_Filter_SpiroTextile_v2(subjs,n_subjs,l_freq,h_freq,flt_ord,srate);
subjs = subjs_tmp; clear subjs_tmp;
disp('Data BP filtered - New field created: bpflt');
%% 2 & 3 - Run PCA and Select the Number of component to explain the \alpha % of the signal
variance_explained_perc_thres = 95; %

subjs_tmp = [];
subjs_tmp = Run_PCA_v1(subjs,variance_explained_perc_thres);
subjs = subjs_tmp; clear subjs_tmp;
disp('PCA Computed - New field created: PCA');
%% 4 & 5 - Compute the weight of a single sensor on all PCs kept
subjs_tmp = [];
subjs_tmp = Compute_Sensor_Weight_Over_PCs_Kept_v1(subjs);
subjs = subjs_tmp; clear subjs_tmp;
disp('Weigths of sensors on PCs kept computed');
%% 5 - Discard all sensors with a weight less then \alpha %, with \alpha ranging in 5÷10 % (to be selected). In this way we have discarded all the sensors that carry more noise
discard_perc_thres = 15; % [%]
subjs_tmp = [];
subjs_tmp = Discard_Noisy_Sensors_Using_Weigth_On_PCA_v1(subjs, discard_perc_thres);
subjs = subjs_tmp; clear subjs_tmp;
disp('Noisy sensors discarded - New Field created: clean_sensors');
%% 6 & 7 - Check for redundand sensors in order to optimize the number. If there are, remove that contribute less on PCs
corr_thresh = 80; %
subjs_tmp = [];
subjs_tmp = Discard_Redundant_Sensors_v1(subjs, corr_thresh);
subjs = subjs_tmp; clear subjs_tmp;
disp('Redundant sensors discarded - New Field created: sensors_reduced');
%% 8 - Run Old Analysis (massaroni 2019 ieee sens j)
subjs_tmp = [];
subjs_tmp = Run_ValutaPSD_v1(subjs);
subjs = subjs_tmp; clear subjs_tmp;
disp('Prior analysis completed');
%% 9 - Get data for most used sensors
% According to the results presented in A1 and B1, the average number of
% sensors used in all trials, averaged on all subects is equal to 3
% (almost). This result takes into account non-redundant sensors, therefore
% this comes from the two discarding parts. Specifically, the following
% values of percentage use was computed:
% - Sensor 3: 83.3 % overall
% - Sensor 5: 65 % overall
% - Sensor 1: 61.7 % overall
% Interestingly, whereas sensors placed on both the upper and lower thorax
% tend to be used singularly, i.e. for all speeds sensors placed on the
% same line result to be redundant to each other, therefore the algorithm
% choose only one of them (the one which weights mostly on the PC
% computed), the sensors placed on the abdomen result to be redunt for
% lower speeds, but used both when the speed increases, specifically in all
% cases of running. For such a reason, insted of using only the three most
% used sensors to check the performaces, we opted to used four ones, using
% one sensor for each of the two bands upon the trhorax, whereas both
% sensors for the band placed on the abdomen. Therefore, the sensors used
% for the final perfermance check and their specific percentage use are the
% follwing:
% - Sensor 3: 83.3 % overall
% - Sensor 5: 65 % overall
% - Sensor 1: 61.7 % overall
% - Sensor 6: 48.3 % overall
% It is noteworthy, that despite the percentage use of the sensor 6 is
% lower than the 50%, it is actually used with a 48.3 percetange, thus in
% line with the discussion above.
best_sensors = [1,3,5,6];
subjs_tmp = [];
subjs_tmp = Best_Sensors_v1(subjs,best_sensors);
subjs = subjs_tmp; clear subjs_tmp;
disp('Analysis on Best Sensors completed');
%% Results
%% A1 - Get Percentage of use for each non-redundant sensor
sensors_perc_use_over_subjects_cell = [];
sensors_perc_use_over_speeds_cell = [];
sensors_perc_use_overall_cell = [];
n_sensors_used = [];

[sensors_perc_use_over_subjects_cell, sensors_perc_use_over_speeds_cell,...
    sensors_perc_use_overall_cell, n_sensors_used] = Evaluate_Sensors_Use_v5(subjs,'non_redundant_sensors');

speeds = num2cell(1:6);
subjs_ids = num2cell(1:n_subjs);
sensors = num2cell(1:6);

var_name1 = {'Sensors','Subject 1 [%]','Subject 2 [%]','Subject 3 [%]','Subject 4 [%]','Subject 5 [%]',...
    'Subject 6 [%]','Subject 7 [%]','Subject 8 [%]','Subject 9 [%]','Subject 10 [%]'};
var_name2 = {'Sensors','Speed 1 [%]','Speed 2 [%]','Speed 3 [%]','Speed 4 [%]','Speed 5 [%]','Speed 6 [%]'};
var_name3 = {'Sensor 1 [%]','Sensor 2 [%]','Sensor 3 [%]','Sensor 4 [%]','Sensor 5 [%]','Sensor 6 [%]'};

disp('A1 - Get Percentage of use for each non-redundant sensor');

sensors_perc_use_over_subjects_tbl = cell2table([sensors',sensors_perc_use_over_subjects_cell],'VariableNames',var_name1)
sensors_perc_use_over_speeds_tbl = cell2table([sensors',sensors_perc_use_over_speeds_cell],'VariableNames',var_name2)
sensors_perc_use_overall_tbl = cell2table(sensors_perc_use_overall_cell','VariableNames',var_name3)
%% A2 - Get Percentage of use for each clean sensor
sensors_clean_perc_use_over_subjects_cell = [];
sensors_clean_perc_use_over_speeds_cell = [];
sensors_clean_perc_use_overall_cell = [];
n_sensors_clean_used = [];

[sensors_clean_perc_use_over_subjects_cell, sensors_clean_perc_use_over_speeds_cell,...
    sensors_clean_perc_use_overall_cell, n_sensors_clean_used] = Evaluate_Sensors_Use_v5(subjs,'clean_sensors');

speeds = num2cell(1:6);
subjs_ids = num2cell(1:n_subjs);
sensors = num2cell(1:6);

var_name1 = {'Sensors','Subject 1 [%]','Subject 2 [%]','Subject 3 [%]','Subject 4 [%]','Subject 5 [%]',...
    'Subject 6 [%]','Subject 7 [%]','Subject 8 [%]','Subject 9 [%]','Subject 10 [%]'};
var_name2 = {'Sensors','Speed 1 [%]','Speed 2 [%]','Speed 3 [%]','Speed 4 [%]','Speed 5 [%]','Speed 6 [%]'};
var_name3 = {'Sensor 1 [%]','Sensor 2 [%]','Sensor 3 [%]','Sensor 4 [%]','Sensor 5 [%]','Sensor 6 [%]'};

disp('A2 - Get Percentage of use for each clean sensor');

sensors_clean_perc_use_over_subjects_tbl = cell2table([sensors',sensors_clean_perc_use_over_subjects_cell],'VariableNames',var_name1)
sensors_clean_perc_use_over_speeds_tbl = cell2table([sensors',sensors_clean_perc_use_over_speeds_cell],'VariableNames',var_name2)
sensors_clean_perc_use_overall_tbl = cell2table(sensors_clean_perc_use_overall_cell','VariableNames',var_name3)
%% B1 - Number of non-redundant sensors used
var_name1 = {'# of Sensors Used','Subject 1','Subject 2','Subject 3','Subject 4','Subject 5',...
    'Subject 6','Subject 7','Subject 8','Subject 9','Subject 10 [%]'};
var_name2 = {'# of Sensors Used','Speed 1','Speed 2','Speed 3','Speed 4','Speed 5','Speed 6'};
var_name3 = {'# of Sensors Used','Total Uses'};

disp('B1 - Number of non-redundant sensors used');

n_sensors_used_over_subjects_tbl = cell2table(['n',num2cell(n_sensors_used.mean_along_speeds_over_subjects')],'VariableNames',var_name1)
n_sensors_used_over_speed_tbl = cell2table(['n',num2cell(n_sensors_used.mean_along_subjects_over_speed)],'VariableNames',var_name2)
n_sensors_used_overlall = cell2table(['n',num2cell(n_sensors_used.mean_use)],'VariableNames',var_name3)
%% B2 - Number of lclean sensors used
var_name1 = {'# of Sensors Used','Subject 1','Subject 2','Subject 3','Subject 4','Subject 5',...
    'Subject 6','Subject 7','Subject 8','Subject 9','Subject 10 [%]'};
var_name2 = {'# of Sensors Used','Speed 1','Speed 2','Speed 3','Speed 4','Speed 5','Speed 6'};
var_name3 = {'# of Sensors Used','Total Uses'};

disp('B2 - Number of clean sensors used');

n_sensors_clean_used_over_subjects_tbl = cell2table(['n',num2cell(n_sensors_clean_used.mean_along_speeds_over_subjects')],'VariableNames',var_name1)
n_sensors_clean_used_over_speed_tbl = cell2table(['n',num2cell(n_sensors_clean_used.mean_along_subjects_over_speed)],'VariableNames',var_name2)
n_sensors_clean_used_overlall = cell2table(['n',num2cell(n_sensors_clean_used.mean_use)],'VariableNames',var_name3)
%% C1 - Correlation between the first pricipal component and spirometer in time domain (spirometer raw)
% the first componet returned by the PCA is the one that explains the
% highest amoung of the signal variance. Thus, if in all cases the
% correlation between the reference signal and the PC1 is high enough, we
% might use PC1 instead of considering all data. Moreover, implementing a
% PCA is not diffecult even considering a portable application (such as
% developed in C++ or other linguages; we would just need a math library
% capable to deal with matrices).

correlations_pc1_spiro = [];
subjs_tmp = [];

[subjs_tmp, correlations_pc1_spiro] = Run_Correlation_PC_Spiro_v2(subjs,'time','first','spiro_raw');

subjs = subjs_tmp;
R_pc1spiro_ave = [];
R_pc1spiro_ave = mean(abs(correlations_pc1_spiro.R),1);

R_pc1spiro_cell = num2cell(correlations_pc1_spiro.R);
var_explained_pc1 = num2cell(correlations_pc1_spiro.var_explained);
R_pc1spiro_ave_cell = num2cell(R_pc1spiro_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl PC1 - Speed 1','Var expl PC1 - Speed 2','Var expl PC1 - Speed 3','Var expl PC1 - Speed 4','Var expl PC1 - Speed 5','Var expl PC1 - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('C1 - Correlation between the first pricipal component and spirometer in time domain');

R_pc1_spiro_tbl = cell2table([subjs_ids',R_pc1spiro_cell],'VariableNames',var_names4)
var_explained_pc1_tbl = cell2table([subjs_ids',var_explained_pc1],'VariableNames',var_names5)
R_pc1spiro_ave_tbl = cell2table(R_pc1spiro_ave_cell,'VariableNames',var_names6)
%% C2 - Correlation between the first pricipal component and spirometer in time domain (integral of spirometer)
% the first componet returned by the PCA is the one that explains the
% highest amoung of the signal variance. Thus, if in all cases the
% correlation between the reference signal and the PC1 is high enough, we
% might use PC1 instead of considering all data. Moreover, implementing a
% PCA is not diffecult even considering a portable application (such as
% developed in C++ or other linguages; we would just need a math library
% capable to deal with matrices).

% The correlation is performed between the integral of the spirometer
% singal (related with the flow, thus hypotetically in phase with the
% textile signal) and the first principal component computed above.
correlations_pc1_spiro_int = [];
subjs_tmp = [];

[subjs_tmp, correlations_pc1_spiro_int] = Run_Correlation_PC_Spiro_v2(subjs,'time','first','spiro_int');

subjs = subjs_tmp;
R_pc1spiro_ave = [];
R_pc1spiro_ave = mean(abs(correlations_pc1_spiro_int.R),1);

R_pc1spiro_cell = num2cell(correlations_pc1_spiro_int.R);
var_explained_pc1 = num2cell(correlations_pc1_spiro_int.var_explained);
R_pc1spiro_ave_cell = num2cell(R_pc1spiro_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl PC1 - Speed 1','Var expl PC1 - Speed 2','Var expl PC1 - Speed 3','Var expl PC1 - Speed 4','Var expl PC1 - Speed 5','Var expl PC1 - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('C2 - Correlation between the first pricipal component and spirometer in time domain');

R_pc1_spiro_tbl = cell2table([subjs_ids',R_pc1spiro_cell],'VariableNames',var_names4)
var_explained_pc1_tbl = cell2table([subjs_ids',var_explained_pc1],'VariableNames',var_names5)
R_pc1spiro_ave_tbl = cell2table(R_pc1spiro_ave_cell,'VariableNames',var_names6)
%% D1 - Correlation between the average of the components needed to explain the 95% of the textile signal and Spirometer Signal in time domain  (spirometer raw)

% The correlation is performed between the integral of the spirometer
% singal (related with the flow, thus hypotetically in phase with the
% textile signal) and the first principal component computed above.
correlations_pcred_spiro = [];
subjs_tmp = [];

[subjs_tmp, correlations_pcred_spiro] = Run_Correlation_PC_Spiro_v2(subjs,'time','all','spiro_raw');

subjs = subjs_tmp;
R_pcred_spiro_ave = [];
R_pcred_spiro_ave = mean(abs(correlations_pcred_spiro.R),1);

R_pcredspiro_cell = num2cell(correlations_pcred_spiro.R);
var_explained_pcred_spiro_cell = num2cell(correlations_pcred_spiro.var_explained);
R_pcred_spiro_ave_cell = num2cell(R_pcred_spiro_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl - Speed 1','Var expl - Speed 2','Var expl - Speed 3','Var expl - Speed 4','Var expl - Speed 5','Var expl - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('D1 - Correlation between the average of the components needed to explain the 95% of the textile signal and Spirometer Signal in time domain');

R_pcred_spiro_tbl = cell2table([subjs_ids',R_pcredspiro_cell],'VariableNames',var_names4)
var_explained_pcred_spiro_tbl = cell2table([subjs_ids',var_explained_pcred_spiro_cell],'VariableNames',var_names5)
R_pcred_spiro_ave_tbl = cell2table(R_pcred_spiro_ave_cell,'VariableNames',var_names6)
%% D2 - Correlation between the average of the components needed to explain the 95% of the textile signal and Spirometer Signal in time domain (integral of spirometer)

% The correlation is performed between the integral of the spirometer
% singal (related with the flow, thus hypotetically in phase with the
% textile signal) and the first principal component computed above.
correlations_pcred_spiro_int = [];
subjs_tmp = [];

[subjs_tmp, correlations_pcred_spiro_int] = Run_Correlation_PC_Spiro_v2(subjs,'time','all','spiro_int');

subjs = subjs_tmp;
R_pcred_spiro_ave = [];
R_pcred_spiro_ave = mean(abs(correlations_pcred_spiro_int.R),1);

R_pcredspiro_cell = num2cell(correlations_pcred_spiro_int.R);
var_explained_pcred_spiro_cell = num2cell(correlations_pcred_spiro_int.var_explained);
R_pcred_spiro_ave_cell = num2cell(R_pcred_spiro_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl - Speed 1','Var expl - Speed 2','Var expl - Speed 3','Var expl - Speed 4','Var expl - Speed 5','Var expl - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('D2 - Correlation between the average of the components needed to explain the 95% of the textile signal and Spirometer Signal in time domain');

R_pcred_spiro_tbl = cell2table([subjs_ids',R_pcredspiro_cell],'VariableNames',var_names4)
var_explained_pcred_spiro_tbl = cell2table([subjs_ids',var_explained_pcred_spiro_cell],'VariableNames',var_names5)
R_pcred_spiro_ave_tbl = cell2table(R_pcred_spiro_ave_cell,'VariableNames',var_names6)
%% E1 - Correlation between the first pricipal component and the Spirometer Signal in frequency domain (spirometer raw)

% the signal of the spirometer is considered as the integral of the
% recorded signal. This one represents the flow instead of the pressure

correlations_pc1_spiro_freq = [];
subjs_tmp = [];

[subjs_tmp, correlations_pc1_spiro_freq] = Run_Correlation_PC_Spiro_v2(subjs,'frequency','first','spiro_raw');

subjs = subjs_tmp;
R_pc1_spiro_freq_ave = [];
R_pc1_spiro_freq_ave = mean(abs(correlations_pc1_spiro_freq.R),1);

R_pc1_spiro_freq_cell = num2cell(correlations_pc1_spiro_freq.R);
var_explained_pc1_spiro_freq_cell = num2cell(correlations_pc1_spiro_freq.var_explained);
R_pc1_spiro_freq_ave_cell = num2cell(R_pc1_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl - Speed 1','Var expl - Speed 2','Var expl - Speed 3','Var expl - Speed 4','Var expl - Speed 5','Var expl - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('E1 - Correlation between the first pricipal component and the Spirometer Signal in frequency domain');

R_pc1_spiro_freq_tbl = cell2table([subjs_ids',R_pc1_spiro_freq_cell],'VariableNames',var_names4)
var_explained_pc1_spiro_freq_tbl = cell2table([subjs_ids',var_explained_pc1_spiro_freq_cell],'VariableNames',var_names5)
R_pc1_spiro_freq_ave_tbl = cell2table(R_pc1_spiro_freq_ave_cell,'VariableNames',var_names6)
%% E2 - Correlation between the first pricipal component and the Spirometer Signal in frequency domain (integral of spirometer)

% the signal of the spirometer is considered as the integral of the
% recorded signal. This one represents the flow instead of the pressure

correlations_pc1_spiro_int_freq = [];
subjs_tmp = [];

[subjs_tmp, correlations_pc1_spiro_int_freq] = Run_Correlation_PC_Spiro_v2(subjs,'frequency','first','spiro_int');

subjs = subjs_tmp;
R_pc1_spiro_freq_ave = [];
R_pc1_spiro_freq_ave = mean(abs(correlations_pc1_spiro_int_freq.R),1);

R_pc1_spiro_freq_cell = num2cell(correlations_pc1_spiro_int_freq.R);
var_explained_pc1_spiro_freq_cell = num2cell(correlations_pc1_spiro_int_freq.var_explained);
R_pc1_spiro_freq_ave_cell = num2cell(R_pc1_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl - Speed 1','Var expl - Speed 2','Var expl - Speed 3','Var expl - Speed 4','Var expl - Speed 5','Var expl - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('E2 - Correlation between the first pricipal component and the Spirometer Signal in frequency domain');

R_pc1_spiro_freq_tbl = cell2table([subjs_ids',R_pc1_spiro_freq_cell],'VariableNames',var_names4)
var_explained_pc1_spiro_freq_tbl = cell2table([subjs_ids',var_explained_pc1_spiro_freq_cell],'VariableNames',var_names5)
R_pc1_spiro_freq_ave_tbl = cell2table(R_pc1_spiro_freq_ave_cell,'VariableNames',var_names6)
%% F1 - Correlation between the average of the components needed to explain the 95% of the textile signal and the Spirometer Signal in frequency domain (spirometer raw)

% the signal of the spirometer is considered as the integral of the
% recorded signal. This one represents the flow instead of the pressure

correlations_pcred_spiro_freq = [];
subjs_tmp = [];

[subjs_tmp, correlations_pcred_spiro_freq] = Run_Correlation_PC_Spiro_v2(subjs,'frequency','all','spiro_raw');

subjs = subjs_tmp;
R_pcred_spiro_freq_ave = [];
R_pcred_spiro_freq_ave = mean(abs(correlations_pcred_spiro_freq.R),1);

R_pcred_spiro_freq_cell = num2cell(correlations_pcred_spiro_freq.R);
var_explained_pcred_spiro_freq_cell = num2cell(correlations_pcred_spiro_freq.var_explained);
R_pcred_spiro_freq_ave_cell = num2cell(R_pcred_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl - Speed 1','Var expl - Speed 2','Var expl - Speed 3','Var expl - Speed 4','Var expl - Speed 5','Var expl - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('F1 - Correlation between the average of the components needed to explain the 95% of the textile signal and the Spirometer Signal in frequency domain');

R_pcred_spiro_freq_tbl = cell2table([subjs_ids',R_pcred_spiro_freq_cell],'VariableNames',var_names4)
var_explained_pcred_spiro_freq_tbl = cell2table([subjs_ids',var_explained_pcred_spiro_freq_cell],'VariableNames',var_names5)
R_pcred_spiro_freq_ave_tbl = cell2table(R_pcred_spiro_freq_ave_cell,'VariableNames',var_names6)
%% F2 - Correlation between the average of the components needed to explain the 95% of the textile signal and the Spirometer Signal in frequency domain (integral of spirometer)

% the signal of the spirometer is considered as the integral of the
% recorded signal. This one represents the flow instead of the pressure

correlations_pcred_spiro_int_freq = [];
subjs_tmp = [];

[subjs_tmp, correlations_pcred_spiro_int_freq] = Run_Correlation_PC_Spiro_v2(subjs,'frequency','all','spiro_int');

subjs = subjs_tmp;
R_pcred_spiro_freq_ave = [];
R_pcred_spiro_freq_ave = mean(abs(correlations_pcred_spiro_int_freq.R),1);

R_pcred_spiro_freq_sd = [];
R_pcred_spiro_freq_sd = std(abs(correlations_pcred_spiro_int_freq.R),0,1);

R_pcred_spiro_freq_cell = num2cell(correlations_pcred_spiro_int_freq.R);
var_explained_pcred_spiro_freq_cell = num2cell(correlations_pcred_spiro_int_freq.var_explained);
R_pcred_spiro_freq_ave_cell = num2cell(R_pcred_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl - Speed 1','Var expl - Speed 2','Var expl - Speed 3','Var expl - Speed 4','Var expl - Speed 5','Var expl - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('F2 - Correlation between the average of the components needed to explain the 95% of the textile signal and the Spirometer Signal in frequency domain');

R_pcred_spiro_freq_tbl = cell2table([subjs_ids',R_pcred_spiro_freq_cell],'VariableNames',var_names4)
var_explained_pcred_spiro_freq_tbl = cell2table([subjs_ids',var_explained_pcred_spiro_freq_cell],'VariableNames',var_names5)
R_pcred_spiro_freq_ave_tbl = cell2table(R_pcred_spiro_freq_ave_cell,'VariableNames',var_names6)
%% G1 - Correlation between Sum of Textile Cleaned and Spiro raw in frequency domain
correlations_textileClean_spiro_freq = [];
subjs_tmp = [];
[subjs_tmp, correlations_textileClean_spiro_freq] = Run_Correlation_AveSensors_Spiro_v2(subjs,'frequency','cleaned','spiro_raw');
subjs = subjs_tmp;

R_textileClean_spiro_freq_ave = [];
R_textileClean_spiro_freq_ave = mean(abs(correlations_textileClean_spiro_freq.R),1);

R_textileClean_spiro_freq_cell = num2cell(correlations_textileClean_spiro_freq.R);
R_textileClean_spiro_freq_ave_cell = num2cell(R_textileClean_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('G1 - Correlation between Sum of Textile Cleaned and Spiro raw in frequency domain');
R_textileClean_spiro_freq_tbl = cell2table([subjs_ids',R_textileClean_spiro_freq_cell],'VariableNames',var_names4)
R_textileClean_spiro_freq_ave_tbl = cell2table(R_textileClean_spiro_freq_ave_cell,'VariableNames',var_names6)
%% G2 - Correlation between Sum of Textile Non-Redundant and Spiro raw in frequency domain
correlations_textileNonRed_spiro_freq = [];
subjs_tmp = [];
[subjs_tmp, correlations_textileNonRed_spiro_freq] = Run_Correlation_AveSensors_Spiro_v2(subjs,'frequency','non_redundant','spiro_raw');
subjs = subjs_tmp;

R_textileNonRed_spiro_freq_ave = [];
R_textileNonRed_spiro_freq_ave = mean(abs(correlations_textileNonRed_spiro_freq.R),1);
R_textileNonRed_spiro_freq_std = std(abs(correlations_textileNonRed_spiro_freq.R),0,1);

R_textileNonRed_spiro_freq_cell = num2cell(correlations_textileNonRed_spiro_freq.R);
R_textileNonRed_spiro_freq_ave_cell = num2cell(R_textileNonRed_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('G2 - Correlation between Sum of Textile Non-Redundant and Spiro raw in frequency domain');
R_textileNonRed_spiro_freq_tbl = cell2table([subjs_ids',R_textileNonRed_spiro_freq_cell],'VariableNames',var_names4)
R_textileNonRed_spiro_freq_ave_tbl = cell2table(R_textileNonRed_spiro_freq_ave_cell,'VariableNames',var_names6)
%% G3 - Correlation between Sum of Textile Old-Algorithm and Spiro raw in frequency domain
correlations_textileOldAlgorithm_spiro_freq = [];
subjs_tmp = [];
[subjs_tmp, correlations_textileOldAlgorithm_spiro_freq] = Run_Correlation_AveSensors_Spiro_v2(subjs,'frequency','old_algorithm','spiro_raw');
subjs = subjs_tmp;

R_textileOldAlgorithm_spiro_freq_ave = [];
R_textileOldAlgorithm_spiro_freq_ave = mean(abs(correlations_textileOldAlgorithm_spiro_freq.R),1);
R_textileOldAlgorithm_spiro_freq_sd = std(abs(correlations_textileOldAlgorithm_spiro_freq.R),0,1);

R_textileOldAlgorithm_spiro_freq_cell = num2cell(correlations_textileOldAlgorithm_spiro_freq.R);
R_textileOldAlgorithm_spiro_freq_ave_cell = num2cell(R_textileOldAlgorithm_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('G3 - Correlation between Sum of Textile Old-Algorithm and Spiro raw in frequency domain');
R_textileOldAlgorithm_spiro_freq_tbl = cell2table([subjs_ids',R_textileOldAlgorithm_spiro_freq_cell],'VariableNames',var_names4)
R_textileOldAlgorithm_spiro_freq_ave_tbl = cell2table(R_textileOldAlgorithm_spiro_freq_ave_cell,'VariableNames',var_names6)
%% G4 - Correlation between Sum of Best Sensors Analysis and Spiro raw in frequency domain
correlations_textileBestSensors_spiro_freq = [];
subjs_tmp = [];
[subjs_tmp, correlations_textileBestSensors_spiro_freq] = Run_Correlation_AveSensors_Spiro_v2(subjs,'frequency','best_sensors','spiro_raw');
subjs = subjs_tmp;

R_textileBestSensors_spiro_freq_ave = [];
R_textileBestSensors_spiro_freq_ave = mean(abs(correlations_textileBestSensors_spiro_freq.R),1);
R_textileBestSensors_spiro_freq_sd = std(abs(correlations_textileBestSensors_spiro_freq.R),0,1);

R_textileBestSensors_spiro_freq_cell = num2cell(correlations_textileBestSensors_spiro_freq.R);
R_textileBestSensors_spiro_freq_ave_cell = num2cell(R_textileBestSensors_spiro_freq_ave);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names6 = {'R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};

disp('G4 - Correlation between Sum of Best Sensors Analysis and Spiro raw in frequency domain');
R_textileBestSensors_spiro_freq_tbl = cell2table([subjs_ids',R_textileBestSensors_spiro_freq_cell],'VariableNames',var_names4)
R_textileBestSensors_spiro_freq_ave_tbl = cell2table(R_textileBestSensors_spiro_freq_ave_cell,'VariableNames',var_names6)
%% E1 - \Delta F between Non-Redundant Textile and Flowmeter in frequency domain
textile_vs_spiro_frequency_assessment = [];
textile_vs_spiro_frequency_assessment = DeltaF_TextilevsSpiro_v1(subjs);
%% E2 - \Delta F between PCA and flometer
pca_vs_spiro_frq_ass = [];
pca_vs_spiro_frq_ass = DeltaF_PCAvsSpiro_v2(subjs);
%% F1 - Get number of PCs used for each subject in each trial
n_pcs = [];
n_pcs = Get_Number_PCs_Used_v1(subjs);

n_pcs_overspeed_ave = [];
n_pcs_overspeed_sd = [];
n_pcs_overspeed_ave = mean(n_pcs,1);
n_pcs_overspeed_sd = std(n_pcs,0,1);
%% G1 - Assess Consistency of the selected sensors
f_err_cell= []; f_err_bpm_cell= []; sel_senrs_id_cell = [];
[f_err_cell, f_err_bpm_cell, sel_senrs_id_cell] = Assess_Selected_Sensors_Consistency_v1(subjs);
%% Save Data for Performance Analysis
save_str = input('do you want to store elab data? y/n: ','s');
if(strcmp(save_str,'y'))
    CLK=clock;
    YR=num2str(CLK(1),'%04d');
    MTH=num2str(CLK(2),'%02d');
    DAY=num2str(CLK(3),'%02d');
    HOUR=num2str(CLK(4),'%02d');
    MIN=num2str(CLK(5),'%02d');
    SEC=num2str(round(CLK(6)),'%02d');
    date_time = [YR,'-',MTH,'-',DAY,'_',HOUR,'.',MIN];
    
    PathSaveFolder = ['Subjects_Data_Struct_Elab',filesep,'version_',date_time];
    if(exist(PathSaveFolder)~=7) % create new folder if it does not exist
        mkdir(PathSaveFolder);
    end
    
    save([PathSaveFolder,filesep,'Subjects_Data_Struct.mat'], 'subjs', '-v7.3');
    
    disp('data_saved');
end