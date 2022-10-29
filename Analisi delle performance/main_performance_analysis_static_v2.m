%% Run Performance Static Analysis, v2, 23-04-2020
% Di Tocco, Massaroni, Raiano

clear all; close all; clc;

%% Load Data
disp('load strcut containing all data');
disp('the data are stored in folder "Subjects_Data_Struct_Elab"');

[file, path] = uigetfile('*.mat');

load([path,file]);

%% Subject 1 - Speed 0 km/h
subj_chosen = 1;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 2 - Speed 0 km/h
subj_chosen = 2;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 
a=100;    %shift temporale prima di inizio dello spirometro; 
b=100;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 3 - Speed 0 km/h
subj_chosen = 3;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 

a=100;    %shift temporale prima di inizio dello spirometro; 
b=100;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 4 - Speed 0 km/h
subj_chosen = 4;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 

% a=1;    %shift temporale prima di inizio dello spirometro; 
a=50;    %shift temporale prima di inizio dello spirometro; modifica joshua
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b+50:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b+50:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 5 - Speed 0 km/h
subj_chosen = 5;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 

a=1;    %shift temporale prima di inizio dello spirometro; 
b=100;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 6 - Speed 0 km/h
subj_chosen = 6;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 7 - Speed 0 km/h
subj_chosen = 7;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 
a=100;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
% c=1;    %shift temporale prima della fine del garment; 
c=250;    %shift temporale prima della fine del garment; modifica joshua


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=90; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 8 - Speed 0 km/h
subj_chosen = 8;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 
a=1;    %shift temporale prima di inizio dello spirometro; 
b=100;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=300;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=90; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 9 - Speed 0 km/h
subj_chosen = 9;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 

a=1;    %shift temporale prima di inizio dello spirometro; 
b=300;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=90; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Subject 10 - Speed 0 km/h
subj_chosen = 10;
speed_chosen = 1;

subj_id = subjs(subj_chosen).id;
speed_list = [];
speed_list = fieldnames(subjs(subj_chosen).data);
speed_id_tmp = textscan(speed_list{speed_chosen},'%s','delimiter','_');
speed_id = speed_id_tmp{1}{2};

disp(['Precessing Subject: ',subj_id,' - Speed: ', speed_id]);

% When it comes to anlyse static tasks, my field containds only the subject
% id
my_field = subj_id;

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

% Breath-by-breath analysis 

% a=1;    %shift temporale prima di inizio dello spirometro; 
a=50;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=90; SOGLIAGARM=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;

%% Breath-by-Breath analysis for all subjects REF VS SG

reference_respiratory_rate_PSD_static=cell2mat(struct2cell(f_reference))
garment_respiratory_rate_PSD_static=cell2mat(struct2cell(f_SmartGarment))

[reference_respiratory_rate_PSD_static garment_respiratory_rate_PSD_static garment_respiratory_rate_PSD_static-reference_respiratory_rate_PSD_static]

figure('Renderer', 'painters', 'Position', [100 100 300 300])
plot(fRref.S1,fSG.S1,'o')
plot([fRref.S1 fRref.S2 fRref.S3 fRref.S4 fRref.S5 fRref.S6 fRref.S7 fRref.S8 fRref.S9 fRref.S10],[fSG.S1 fSG.S2 fSG.S3 fSG.S4 fSG.S5 fSG.S6 fSG.S7 fSG.S8 fSG.S9 fSG.S10],'o')

BbB_reference_static=[fRref.S1 fRref.S2 fRref.S3 fRref.S4 fRref.S5 fRref.S6 fRref.S7 fRref.S8 fRref.S9 fRref.S10]';
BbB_garment_static=[fSG.S1 fSG.S2 fSG.S3 fSG.S4 fSG.S5 fSG.S6 fSG.S7 fSG.S8 fSG.S9 fSG.S10]';

[BbB_reference_static BbB_garment_static BbB_garment_static-BbB_reference_static]
MAE_static=1/length(BbB_garment_static)*(sum(abs(BbB_garment_static-BbB_reference_static)))
SE_static=std(abs(BbB_garment_static-BbB_reference_static))/sqrt(length(BbB_garment_static))
ERR_PERC=mean(abs(((((BbB_garment_static-BbB_reference_static))./BbB_reference_static)*100)))
ERR_PERC=mean((((((BbB_garment_static-BbB_reference_static))./BbB_reference_static)*100)))

% hist(BbB_garment_static-BbB_reference_static)

BbB_reference_static=BbB_reference_static';
BbB_garment_static=BbB_garment_static';

figure()
[fitresult, gof] = createFit(BbB_reference_static, BbB_garment_static)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1,fSG.S1, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2,fSG.S2, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3,fSG.S3, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4,fSG.S4, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5,fSG.S5, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6,fSG.S6, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7,fSG.S7, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8,fSG.S8, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9,fSG.S9, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10,fSG.S10, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(BbB_reference_static+1),fitresult(0:max(BbB_reference_static+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - Static')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S1',fRref.S1'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S2',fRref.S2'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S3',fRref.S3'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S4',fRref.S4'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S5',fRref.S5'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S6',fRref.S6'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S7',fRref.S7'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S8',fRref.S8'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S9',fRref.S9'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S10',fRref.S10'], 'c','^')
MOD=mean(-BbB_reference_static+BbB_garment_static)
diff=(-BbB_reference_static+BbB_garment_static);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{SG}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')

% xlabel('Mean f_{R}[i] [bpm]')
% ylabel('\Deltaf_{R}[i] [bpm]')

set(gca,'FontSize',14)
title('Static')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])

legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 25])

%% Breath-by-Breath analysis for all subjects REF VS PCA

reference_respiratory_rate_PSD_static=cell2mat(struct2cell(f_reference))
pca_respiratory_rate_PSD_static=cell2mat(struct2cell(f_pca))

[reference_respiratory_rate_PSD_static pca_respiratory_rate_PSD_static pca_respiratory_rate_PSD_static-reference_respiratory_rate_PSD_static]

figure('Renderer', 'painters', 'Position', [100 100 300 300])
plot(fRref.S1,fPCA.S1,'o')
plot([fRref.S1 fRref.S2 fRref.S3 fRref.S4 fRref.S5 fRref.S6 fRref.S7 fRref.S8 fRref.S9 fRref.S10],[fPCA.S1 fPCA.S2 fPCA.S3 fPCA.S4 fPCA.S5 fPCA.S6 fPCA.S7 fPCA.S8 fPCA.S9 fPCA.S10],'o')

BbB_reference_static=[fRref.S1 fRref.S2 fRref.S3 fRref.S4 fRref.S5 fRref.S6 fRref.S7 fRref.S8 fRref.S9 fRref.S10]';
BbB_PCA_static=[fPCA.S1 fPCA.S2 fPCA.S3 fPCA.S4 fPCA.S5 fPCA.S6 fPCA.S7 fPCA.S8 fPCA.S9 fPCA.S10]';

[BbB_reference_static BbB_PCA_static BbB_PCA_static-BbB_reference_static]
MAE_static=1/length(BbB_PCA_static)*(sum(abs(BbB_PCA_static-BbB_reference_static)))
SE_static=std(abs(BbB_PCA_static-BbB_reference_static))/sqrt(length(BbB_PCA_static))
ERR_PERC=mean(abs(((((BbB_PCA_static-BbB_reference_static))./BbB_reference_static)*100)))
ERR_PERC=mean((((((BbB_PCA_static-BbB_reference_static))./BbB_reference_static)*100)))

% hist(BbB_PCA_static-BbB_reference_static)

BbB_reference_static=BbB_reference_static';
BbB_PCA_static=BbB_PCA_static';

figure()
[fitresult, gof] = createFit(BbB_reference_static, BbB_PCA_static)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1,fPCA.S1, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2,fPCA.S2, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3,fPCA.S3, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4,fPCA.S4, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5,fPCA.S5, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6,fPCA.S6, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7,fPCA.S7, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8,fPCA.S8, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9,fPCA.S9, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10,fPCA.S10, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(BbB_reference_static+1),fitresult(0:max(BbB_reference_static+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - Static')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S1',fRref.S1'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S2',fRref.S2'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S3',fRref.S3'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S4',fRref.S4'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S5',fRref.S5'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S6',fRref.S6'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S7',fRref.S7'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S8',fRref.S8'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S9',fRref.S9'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S10',fRref.S10'], 'c','^')
MOD=mean(-BbB_reference_static+BbB_PCA_static)
diff=(-BbB_reference_static+BbB_PCA_static);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')

% xlabel('Mean f_{R}[i] [bpm]')
% ylabel('\Deltaf_{R}[i] [bpm]')

set(gca,'FontSize',14)
title('Static')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])

legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 25])


