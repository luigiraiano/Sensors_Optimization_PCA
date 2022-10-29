%% NOTE:
% v2 discards CM and CT versions because they do not have all speeds
%% Luigi Raiano, v2, 24-03-2020
clear all; close all; clc;
addpath('functions_new');
addpath('FastICA_25');
%% choose data (struct in a mat file)
disp('Choose the mat file containing the strcu in which are acontained the data of alla subjects');
[file,path] = uigetfile('*.mat');

% load file
load([path,file]);
disp('data loaded');

subjs_new = [];
subjs_new = subjs;
% remove CT and CM which are subjs(2) and subjs(3) respectively.
subjs_new(2) = []; % CM removed
subjs_new(2) = []; % CT removed

n_subjs = length(subjs_new);

srate = 250;
%% Band Pass Filtering
% filter only segmented data
l_freq = 0.05; % Hz
h_freq = 2; % Hz
flt_ord = 2;

subjs_tmp = [];
subjs_tmp = BandPass_Filter_SpiroTextile_v1(subjs_new,n_subjs,l_freq,h_freq,flt_ord,srate);
subjs_new = subjs_tmp; clear subjs_tmp;
disp('Data BP filtered - - New field created: bpflt');
%% Run PCA
explained_perc_thres = 95; %

subjs_tmp = [];
subjs_tmp = Run_PCA_v1(subjs_new,explained_perc_thres);
subjs_new = subjs_tmp; clear subjs_tmp;
disp('PCA Computed - New field created: PCA');
%% Keep sensors on the basis of the PCA results
corr_thresh = 95; %

subjs_tmp = [];
subjs_tmp = Sensors_Selection_PCA_Based_v1(subjs_new, corr_thresh);
subjs_new = subjs_tmp; clear subjs_tmp;
disp('PCA Computed - New field created: sensor_reduced');
%% Get Percentage of usage for each sensor
sensors_perc_use_over_subjects_cell = [];
sensors_perc_use_over_speeds_cell = [];
sensors_perc_use_overall_cell = [];
[sensors_perc_use_over_subjects_cell, sensors_perc_use_over_speeds_cell, sensors_perc_use_overall_cell]...
    = Evaluate_Sensors_Use_v1(subjs_new);

speeds = num2cell(1:6);
subjs_ids = num2cell(1:n_subjs);
sensors = num2cell(1:6);

var_name1 = {'Sensors','Subject 1 [%]','Subject 2 [%]','Subject 3 [%]','Subject 4 [%]','Subject 5 [%]',...
    'Subject 6 [%]','Subject 7 [%]'};
var_name2 = {'Sensors','Speed 1 [%]','Speed 2 [%]','Speed 3 [%]','Speed 4 [%]','Speed 5 [%]','Speed 6 [%]'};
var_name3 = {'Sensor 1 [%]','Sensor 2 [%]','Sensor 3 [%]','Sensor 4 [%]','Sensor 5 [%]','Sensor 6 [%]'};

sensors_perc_use_over_subjects_tbl = cell2table([sensors',sensors_perc_use_over_subjects_cell],'VariableNames',var_name1)
sensors_perc_use_over_speeds_tbl = cell2table([sensors',sensors_perc_use_over_speeds_cell],'VariableNames',var_name2)
sensors_perc_use_overall_tbl = cell2table(sensors_perc_use_overall_cell','VariableNames',var_name3)
%% Correlation between the first pricipal component and spirometer
% the first componet returned by the PCA is the one that explains the
% highest amoung of the signal variance. Thus, if in all cases the
% correlation between the reference signal and the PC1 is high enough, we
% might use PC1 instead of considering all data. Moreover, implementing a
% PCA is not diffecult even considering a portable application (such as
% developed in C++ or other linguages; we would just need a math library
% capable to deal with matrices).
correlations = [];
subjs_tmp = [];
[subjs_tmp, correlations] =Run_Correlation_MainPC_Spiro_v1(subjs_new);
subjs_new = subjs_tmp;

R_pc1spiro_cell = num2cell(correlations.R);
var_explained_pc1 = num2cell(correlations.var_expl_pc1);

var_names4 = {'Subjects','R - Speed 1','R - Speed 2','R - Speed 3','R - Speed 4','R - Speed 5','R - Speed 6'};
var_names5 = {'Subjects','Var expl PC1 - Speed 1','Var expl PC1 - Speed 2','Var expl PC1 - Speed 3','Var expl PC1 - Speed 4','Var expl PC1 - Speed 5','Var expl PC1 - Speed 6'};

R_pc1spiro_tbl = cell2table([subjs_ids',R_pc1spiro_cell],'VariableNames',var_names4)
var_explained_pc1_tbl = cell2table([subjs_ids',var_explained_pc1],'VariableNames',var_names5)