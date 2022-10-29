%% Run Performance Dynamic Analysis, v1, 10-04-2020
% Di Tocco, Massaroi, Raiano

clear all; close all; clc;

%% Load Data
disp('load strcut containing all data');
disp('the data are stored in folder "Subjects_Data_Struct_Elab"');

[file, path] = uigetfile('*.mat');

load([path,file]);
%% Subject 1 - Speed 1.6 km/h
subj_chosen = 1;
speed_chosen = 2;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my foeld containds only the subject
% id
my_field = [subj_id, '_', speed_id];

% frequenza media
% Spirometro 
f_reference.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).bpflt.f_spiro;		% frequ riferimento picco max PSD
f_referenceBP.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).bpflt.f_spiro_bpm ;	% frequ riferimento picco max PSD in bpm

% articolo vecchio
f_SmartGarment.(my_field) =subjs(subj_chosen).data.(speed_list{speed_chosen}).algoritmo_precedente.f_sg;		% frequ maglia picco max PSD (quattrosegnali)
f_SmartGarmentBP.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).algoritmo_precedente.f_sgbpm;	% frequ maglia picco max PSD in bpm (quattrosegnali)
signal4sensors.(my_field)= subjs(subj_chosen).data.(speed_list{speed_chosen}).algoritmo_precedente.textile_4_sensori;

% segnali puliti sulla base della pca (no segnali ruomosi)
signal_clean_sensors.(my_field).sensors_label = subjs(subj_chosen).data.(speed_list{speed_chosen}).clean_sensors.sensors_tokeep;% label of the kep sensors after first discarding
signal_clean_sensors.(my_field).all = subjs(subj_chosen).data.(speed_list{speed_chosen}).clean_sensors.segnale_textile;% data of the kep sensors after first discarding
signal_clean_sensors.(my_field).ave = mean(subjs(subj_chosen).data.(speed_list{speed_chosen}).clean_sensors.segnale_textile,2);
f_textile_clean.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).clean_sensors.f_clean; % Hz
f_textile_bpm_clean.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).clean_sensors.fbpm_clean; % bpm

% segnali non-ridondanti
signal_nonred_sensors.(my_field).sensors_label = subjs(subj_chosen).data.(speed_list{speed_chosen}).sensors_reduced.sensors_tokeep;% label of the kep sensors after second discarding
signal_nonred_sensors.(my_field).all = subjs(subj_chosen).data.(speed_list{speed_chosen}).sensors_reduced.segnale_textile;% data of the kep sensors after second discarding
signal_nonred_sensors.(my_field).ave = mean(subjs(subj_chosen).data.(speed_list{speed_chosen}).sensors_reduced.segnale_textile,2);
f_textile_nonred.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).sensors_reduced.f_nonred; % Hz
f_textile_bpm_nonred.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).sensors_reduced.fbpm_nonred; % bpm

% componenti principali nel tempo
signal_pcs.(my_field).all = subjs(subj_chosen).data.(speed_list{speed_chosen}).PCA.textile_rot_reduced;
signal_pcs.(my_field).ave = mean(subjs(subj_chosen).data.(speed_list{speed_chosen}).PCA.textile_rot,2);
f_pca.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).PCA.f_pca; % Hz
f_bpm_pca.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).PCA.fbpm_pca; % bpm

% Spiro ref
tempo_spiro_RT_W = subjs(subj_chosen).data.(speed_list{speed_chosen}).bpflt.tempo_spiro;
segnale_spiro_RT_W = subjs(subj_chosen).data.(speed_list{speed_chosen}).bpflt.segnale_spiro;

% All sensors
tempo_textile_RT_W = subjs(subj_chosen).data.(speed_list{speed_chosen}).bpflt.tempo_textile;
segnale_textile_RT_W = subjs(subj_chosen).data.(speed_list{speed_chosen}).bpflt.segnale_textile;

% Analisi su Best Sensors
signal_best_sensors.(my_field).sensors_label = subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.labels;
signal_best_sensors.(my_field).all = subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.segnale_textile;
signal_best_sensors.(my_field).somma = sum(subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.segnale_textile,2);
signal_best_sensors.(my_field).ave = mean(subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.segnale_textile,2);
f_textile_bestSensors.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.f_max;
f_textile_bpm_bestSensors.(my_field) = subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.f_max_bpm;