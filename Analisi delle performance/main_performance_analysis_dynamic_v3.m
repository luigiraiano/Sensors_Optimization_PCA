%% Run Performance Dynamic Analysis,v3, 28-04-2020
% Di Tocco, Massaroni, Raiano

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

% Breath-by-Breath

a=400;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 
d=1;  %shift temporale prima della fine dello spirometro; 
% c=1;    %shift temporale prima della fine del garment; 
c=250;    %shift temporale prima della fine del garment; modificato joshua

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;


% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 1 - Speed 3.0 km/h
subj_chosen = 1;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 1 - Speed 5.0 km/h
subj_chosen = 1;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

% d=1;  %shift temporale prima della fine dello spirometro; 
d=250;  %shift temporale prima della fine dello spirometro; modifica joshua

c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=25; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 1 - Speed 6.6 km/h
subj_chosen = 1;
speed_chosen = 5;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 1 - Speed 8.0 km/h
subj_chosen = 1;
speed_chosen = 6;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Subject 2 - Speed 1.6 km/h
subj_chosen = 2;
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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 2 - Speed 3.0 km/h

subj_chosen = 2;
speed_chosen = 3;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 2 - Speed 5.0 km/h

subj_chosen = 2;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=400;    %shift temporale prima di inizio del garment; 

d=250;  %shift temporale prima della fine dello spirometro; 
c=250;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 2 - Speed 6.6 km/h
subj_chosen = 2;
speed_chosen = 5;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=25; SOGLIAPCA=40;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 2 - Speed 8.0 km/h
subj_chosen = 2;
speed_chosen = 6;

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

% Breath-by-Breath 

a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

% d=1;  %shift temporale prima della fine dello spirometro; 
% c=1;    %shift temporale prima della fine del garment; 
c=100;    %shift temporale prima della fine del garment; modifica joshua
d=250;  %shift temporale prima della fine dello spirometro; modifica joshua 




% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=60;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*150 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;% 5 eliminato a mano
fPCA_nonred.(my_field)=fatto_pca_nonred;% 5 eliminato a mano

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Subject 3 - Speed 1.6 km/h

subj_chosen = 3;
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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=60; SOGLIAPCA=60;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 3 - Speed 3.0 km/h

subj_chosen = 3;
speed_chosen = 3;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;
% SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;
SOGLIAREF=50; SOGLIAGARM=80; SOGLIAPCA=80; % modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*90 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*90 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*90 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA+10));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 3 - Speed 5.0 km/h

subj_chosen = 3;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=400;    %shift temporale prima di inizio del garment; 

d=250;  %shift temporale prima della fine dello spirometro; 
c=250;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=57; %modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;


% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field)),length(TPCA.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field)),length(TPCA.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field)),length(TPCA.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field)),length(TPCA.(my_field))]));
% TPCA.(my_field)=durata_atto_pca(1:min([length(Tref.(my_field)),length(TSG.(my_field)),length(TPCA.(my_field))]));
% fPCA.(my_field)=fatto_pca(1:min([length(Tref.(my_field)),length(TSG.(my_field)),length(TPCA.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 3 - Speed 6.6 km/h
subj_chosen = 3;
speed_chosen = 5;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=46;%modifica joshua

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*100 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*115 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*115 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 3 - Speed 8.0 km/h
subj_chosen = 3;
speed_chosen = 6;

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

% Breath-by-Breath 

a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

% d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 
d=350;  %shift temporale prima della fine dello spirometro; modifica joshua 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=60;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*150 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end


%% Subject 4 - Speed 1.6 km/h
subj_chosen = 4;
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

% Breath-by-Breath

% a=400;    %shift temporale prima di inizio dello spirometro; 
a=700;    %shift temporale prima di inizio dello spirometro; 

b=1;    %shift temporale prima di inizio del garment; 
d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 
% c=250;    %shift temporale prima della fine del garment; modificato joshua

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b+50:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b+50:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;% eliminato a mano secondo picco
fRref.(my_field)=fatto_ref; % eliminato a mano secondo picco
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 4 - Speed 3.0 km/h
subj_chosen = 4;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;
SOGLIAREF=50; SOGLIAGARM=28; SOGLIAPCA=29; % modifica joshua

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*105 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 4 - Speed 5.0 km/h
subj_chosen = 4;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=40;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 4 - Speed 6.6 km/h
subj_chosen = 4;
speed_chosen = 5;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=250;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=40;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 4 - Speed 8.0 km/h
subj_chosen = 4;
speed_chosen = 6;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=250;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Subject 5 - Speed 1.6 km/h
subj_chosen = 5;
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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 
d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 5 - Speed 3.0 km/h
subj_chosen = 5;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=200;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 5 - Speed 5.0 km/h
subj_chosen = 5;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=30; SOGLIAGARM=40; SOGLIAPCA=47;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-(c+50),:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-(c+50),:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 5 - Speed 6.6 km/h
subj_chosen = 5;
speed_chosen = 5;

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

% Breath-by-Breath

% a=200;    %shift temporale prima di inizio dello spirometro; 
a=500;    %shift temporale prima di inizio dello spirometro; modifica joshua
% b=1;    %shift temporale prima di inizio del garment; 
b=300;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=40;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*100 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*100 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 5 - Speed 8.0 km/h
subj_chosen = 5;
speed_chosen = 6;

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

% Breath-by-Breath

% a=1;    %shift temporale prima di inizio dello spirometro; 
a=250;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Subject 6 - Speed 1.6 km/h
subj_chosen = 6;
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

% Breath-by-Breath
a=80;    %shift temporale prima di inizio dello spirometro;
b=200;    %shift temporale prima di inizio del garment;
 
d=150;  %shift temporale prima della fine dello spirometro;
c=10;    %shift temporale prima della fine del garment;


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 6 - Speed 3.0 km/h
subj_chosen = 6;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=400;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 6 - Speed 5.0 km/h
subj_chosen = 6;
speed_chosen = 4;

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

% Breath-by-Breath

a=100;    %shift temporale prima di inizio dello spirometro; 
b=100;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=70; SOGLIAPCA=70;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*110 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;% eliminato quartultimo e penultimo
fSG.(my_field)=fatto_garment;% eliminato quartultimo e penultimo
TPCA.(my_field)=durata_atto_pca;% eliminato terzultimo
fPCA.(my_field)=fatto_pca;% eliminato terzultimo
TPCA_nonred.(my_field)=durata_atto_pca_nonred;% eliminato terzultimo
fPCA_nonred.(my_field)=fatto_pca_nonred;% eliminato terzultimo

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 6 - Speed 6.6 km/h
subj_chosen = 6;
speed_chosen = 5;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=400;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 6 - Speed 8.0 km/h
subj_chosen = 6;
speed_chosen = 6;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro;
b=250;    %shift temporale prima di inizio del garment;
 
d=10;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;
 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*100 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end


%% Subject 7 - Speed 1.6 km/h
subj_chosen = 7;
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

% Breath-by-Breath

a=250;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 7 - Speed 3.0 km/h
subj_chosen = 7;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 7 - Speed 5.0 km/h
subj_chosen = 7;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

% d=1;  %shift temporale prima della fine dello spirometro; 
d=350;  %shift temporale prima della fine dello spirometro; modifica joshua
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=25; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 7 - Speed 6.6 km/h
subj_chosen = 7;
speed_chosen = 5;

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

% Breath-by-Breath


a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

% d=1;  %shift temporale prima della fine dello spirometro; 
% c=1;    %shift temporale prima della fine del garment; 
d=250;  %shift temporale prima della fine dello spirometro; 
c=250;    %shift temporale prima della fine del garment; 

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 7 - Speed 8.0 km/h
subj_chosen = 7;
speed_chosen = 6;

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

% Breath-by-Breath


% a=1;    %shift temporale prima di inizio dello spirometro; 
a=250;    %shift temporale prima di inizio dello spirometro; 

b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Subject 8 - Speed 1.6 km/h
subj_chosen = 8;
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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro;
b=1;    %shift temporale prima di inizio del garment;
 
d=1;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;
 

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 8 - Speed 3.0 km/h
subj_chosen = 8;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
% c=1;    %shift temporale prima della fine del garment; 
c=350;    %shift temporale prima della fine del garment; 



% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;% eliminato ultimo a mano
fPCA_nonred.(my_field)=fatto_pca_nonred;% eliminato ultimo a mano

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 8 - Speed 5.0 km/h
subj_chosen = 8;
speed_chosen = 4;

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

% Breath-by-Breath

a=200;    %shift temporale prima di inizio dello spirometro;
b=200;    %shift temporale prima di inizio del garment;
 
d=1;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;
 

% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=25; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 8 - Speed 6.6 km/h
subj_chosen = 8;
speed_chosen = 5;

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

% Breath-by-Breath

a=250;    %shift temporale prima di inizio dello spirometro;
b=250;    %shift temporale prima di inizio del garment;
 
d=100;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;
 

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 8 - Speed 8.0 km/h
subj_chosen = 8;
speed_chosen = 6;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro;
b=1;    %shift temporale prima di inizio del garment;
 
d=100;  %shift temporale prima della fine dello spirometro;
c=100;    %shift temporale prima della fine del garment;

% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end


%% Subject 9 - Speed 1.6 km/h
subj_chosen = 9;
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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro;
b=1;    %shift temporale prima di inizio del garment;
 
d=1;  %shift temporale prima della fine dello spirometro;
% c=1;    %shift temporale prima della fine del garment;
c=250;    %shift temporale prima della fine del garment;


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 9 - Speed 3.0 km/h
subj_chosen = 9;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

d=1;  %shift temporale prima della fine dello spirometro; 
% c=1;    %shift temporale prima della fine del garment; 
c=250;    %shift temporale prima della fine del garment; 



% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 9 - Speed 5.0 km/h
subj_chosen = 9;
speed_chosen = 4;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro;
b=100;    %shift temporale prima di inizio del garment;
 
d=1;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 9 - Speed 6.6 km/h
subj_chosen = 9;
speed_chosen = 5;

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

% Breath-by-Breath

a=100;    %shift temporale prima di inizio dello spirometro;
b=100;    %shift temporale prima di inizio del garment;
 
d=1;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=60;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*150 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*150 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 9 - Speed 8.0 km/h
subj_chosen = 9;
speed_chosen = 6;

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

% Breath-by-Breath

a=1;    %shift temporale prima di inizio dello spirometro;
b=100;    %shift temporale prima di inizio del garment;
 
d=150;  %shift temporale prima della fine dello spirometro;
c=150;    %shift temporale prima della fine del garment;


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=70; SOGLIAPCA=90;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*150 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*150 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*150 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Subject 10 - Speed 1.6 km/h
subj_chosen = 10;
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

% Breath-by-Breath

 
a=1;    %shift temporale prima di inizio dello spirometro;
b=1;    %shift temporale prima di inizio del garment;
 
% d=1;  %shift temporale prima della fine dello spirometro;
d=350;  %shift temporale prima della fine dello spirometro; modifica joshua
c=250;    %shift temporale prima della fine del garment;

% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50;  SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));


if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 10 - Speed 3.0 km/h
subj_chosen = 10;
speed_chosen = 3;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro; 
b=1;    %shift temporale prima di inizio del garment; 

% d=1;  %shift temporale prima della fine dello spirometro; 
d=350;  %shift temporale prima della fine dello spirometro; 
c=1;    %shift temporale prima della fine del garment; 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))


Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 10 - Speed 5.0 km/h
subj_chosen = 10;
speed_chosen = 4;

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

% Breath-by-Breath

% a=1;    %shift temporale prima di inizio dello spirometro;
a=250;    %shift temporale prima di inizio dello spirometro;
b=1;    %shift temporale prima di inizio del garment;
 
d=1;  %shift temporale prima della fine dello spirometro;
c=1;    %shift temporale prima della fine del garment;


% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50; 
SOGLIAREF=50; SOGLIAGARM=25; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 10 - Speed 6.6 km/h
subj_chosen = 10;
speed_chosen = 5;

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

% Breath-by-Breath


a=1;    %shift temporale prima di inizio dello spirometro;
% b=1;    %shift temporale prima di inizio del garment;
b=350;    %shift temporale prima di inizio del garment;

d=1;  %shift temporale prima della fine dello spirometro;
c=100;    %shift temporale prima della fine del garment;
 


% SPIROF=500; GARMENTF=500;  
SOGLIAREF=50; SOGLIAGARM=50; SOGLIAPCA=50;

[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

% Subject 10 - Speed 8.0 km/h
subj_chosen = 10;
speed_chosen = 6;

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

% Breath-by-Breath
a=1;    %shift temporale prima di inizio dello spirometro;
b=1;    %shift temporale prima di inizio del garment;
 
% d=1;  %shift temporale prima della fine dello spirometro;
d=350;  %shift temporale prima della fine dello spirometro; modifica joshua
% c=1;    %shift temporale prima della fine del garment;
c=350;    %shift temporale prima della fine del garment; modifica joshua
 
% SPIROF=500; GARMENTF=500;  
% SOGLIAREF=50; SOGLIAGARM=50;
SOGLIAREF=50; SOGLIAGARM=40; SOGLIAPCA=50;% modifica joshua


[ durata_atto_ref fatto_ref] = valutafrequenzarespiratoria(smooth(-zscore(segnale_spiro_RT_W(a:end-d)),250), tempo_spiro_RT_W(a:end-d), 60/f_referenceBP.(my_field)*125 ,-prctile((smooth(zscore(segnale_spiro_RT_W(a:end)),250)),SOGLIAREF));
[ durata_atto_garment fatto_garment] = valutafrequenzarespiratoria(smooth(zscore(sum(signal4sensors.(my_field)(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_SmartGarmentBP.(my_field)*125 ,-prctile(zscore(sum(signal4sensors.(my_field)(b:end,:)')),SOGLIAGARM));
[ durata_atto_pca fatto_pca] = valutafrequenzarespiratoria(smooth(zscore(sum(signal_clean_sensors.(my_field).all(b:end-c,:)')),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(sum(signal_clean_sensors.(my_field).all(b:end,:)')),SOGLIAPCA));
[ durata_atto_pca_nonred fatto_pca_nonred] = valutafrequenzarespiratoria(smooth(zscore(signal_nonred_sensors.(my_field).ave(b:end-c,:)'),250),  tempo_textile_RT_W(b:end-c), 60/f_textile_bpm_clean.(my_field)*125 ,-prctile(zscore(signal_nonred_sensors.(my_field).ave(b:end,:)'),SOGLIAPCA));

title(sprintf('%s',my_field))

Tref.(my_field)=durata_atto_ref;
fRref.(my_field)=fatto_ref;
TSG.(my_field)=durata_atto_garment;
fSG.(my_field)=fatto_garment;
TPCA.(my_field)=durata_atto_pca;
fPCA.(my_field)=fatto_pca;
TPCA_nonred.(my_field)=durata_atto_pca_nonred;
fPCA_nonred.(my_field)=fatto_pca_nonred;

% Tref.(my_field)=Tref.(my_field)(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fRref.(my_field)=fatto_ref(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% TSG.(my_field)=durata_atto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));
% fSG.(my_field)=fatto_garment(1:min([length(Tref.(my_field)),length(TSG.(my_field))]));

if(length(fRref.(my_field))==length(fSG.(my_field)))
figure()
plot(fRref.(my_field)',fSG.(my_field)','x')
hold on
plot(fRref.(my_field)',fPCA.(my_field)','rx')
end

%% Breath-by-Breath analysis SG vs Ref
reference_respiratory_rate_PSD_static=cell2mat(struct2cell(f_reference))
garment_respiratory_rate_PSD_static=cell2mat(struct2cell(f_SmartGarment))

[reference_respiratory_rate_PSD_static garment_respiratory_rate_PSD_static garment_respiratory_rate_PSD_static-reference_respiratory_rate_PSD_static]
bar([reference_respiratory_rate_PSD_static garment_respiratory_rate_PSD_static])
legend('f_{R} Hz reference','f_{R} Hz garment')
labels={'S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80'}
xticklabels(labels)


% Analisi atto-atto

f_Ref_16=vertcat(fRref.S1_16',fRref.S2_16',fRref.S3_16',fRref.S4_16',fRref.S5_16',fRref.S6_16',fRref.S7_16',fRref.S8_16',fRref.S9_16',fRref.S10_16')
f_SG_16=vertcat(fSG.S1_16',fSG.S2_16',fSG.S3_16',fSG.S4_16',fSG.S5_16',fSG.S6_16',fSG.S7_16',fSG.S8_16',fSG.S9_16',fSG.S10_16')

f_Ref_30=vertcat(fRref.S1_30',fRref.S2_30',fRref.S3_30',fRref.S4_30',fRref.S5_30',fRref.S6_30',fRref.S7_30',fRref.S8_30',fRref.S9_30',fRref.S10_30')
f_SG_30=vertcat(fSG.S1_30',fSG.S2_30',fSG.S3_30',fSG.S4_30',fSG.S5_30',fSG.S6_30',fSG.S7_30',fSG.S8_30',fSG.S9_30',fSG.S10_30')

f_Ref_50=vertcat(fRref.S1_50',fRref.S2_50',fRref.S3_50',fRref.S4_50',fRref.S5_50',fRref.S6_50',fRref.S7_50',fRref.S8_50',fRref.S9_50',fRref.S10_50')
f_SG_50=vertcat(fSG.S1_50',fSG.S2_50',fSG.S3_50',fSG.S4_50',fSG.S5_50',fSG.S6_50',fSG.S7_50',fSG.S8_50',fSG.S9_50',fSG.S10_50')

f_Ref_66=vertcat(fRref.S1_66',fRref.S2_66',fRref.S3_66',fRref.S4_66',fRref.S5_66',fRref.S6_66',fRref.S7_66',fRref.S8_66',fRref.S9_66',fRref.S10_66')
f_SG_66=vertcat(fSG.S1_66',fSG.S2_66',fSG.S3_66',fSG.S4_66',fSG.S5_66',fSG.S6_66',fSG.S7_66',fSG.S8_66',fSG.S9_66',fSG.S10_66')

f_Ref_80=vertcat(fRref.S1_80',fRref.S2_80',fRref.S3_80',fRref.S4_80',fRref.S5_80',fRref.S6_80',fRref.S7_80',fRref.S8_80',fRref.S9_80',fRref.S10_80')
f_SG_80=vertcat(fSG.S1_80',fSG.S2_80',fSG.S3_80',fSG.S4_80',fSG.S5_80',fSG.S6_80',fSG.S7_80',fSG.S8_80',fSG.S9_80',fSG.S10_80')


plot(f_Ref_16,f_SG_16,'o')
hold on
plot(f_Ref_30,f_SG_30,'o')
plot(f_Ref_50,f_SG_50,'o')
plot(f_Ref_66,f_SG_66,'o')
plot(f_Ref_80,f_SG_80,'o')

%% analisi separate: 1.6 km/h
figure()
[fitresult, gof] = createFit(f_Ref_16, f_SG_16)
close all
figure('Renderer', 'painters', 'Position', [100 100 500 400])
plot (fRref.S1_16,fSG.S1_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_16,fSG.S2_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_16,fSG.S3_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_16,fSG.S4_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_16,fSG.S5_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_16,fSG.S6_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_16,fSG.S7_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_16,fSG.S8_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_16,fSG.S9_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_16,fSG.S10_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_16+1),fitresult(0:max(f_Ref_16+1)),'k-.','linewidth',2)
xlabel ('f_{R}[i]|_F [breaths\cdotmin^{-1}]')
ylabel ('f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 1.6 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S1_16',fRref.S1_16'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S2_16',fRref.S2_16'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S3_16',fRref.S3_16'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S4_16',fRref.S4_16'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S5_16',fRref.S5_16'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S6_16',fRref.S6_16'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S7_16',fRref.S7_16'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S8_16',fRref.S8_16'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S9_16',fRref.S9_16'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S10_16',fRref.S10_16'], 'c','^')

MOD=mean(f_SG_16-f_Ref_16)
diff=(f_SG_16-f_Ref_16);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{SG}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('1.6 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(f_Ref_16)+min(f_Ref_16)])

MAE_16=1/length(f_Ref_16)*(sum(abs(f_SG_16-f_Ref_16)))
SE_16=std(abs(f_SG_16-f_Ref_16))/sqrt(length(f_SG_16))
ERR_PERC_16=mean(abs(((((f_SG_16-f_Ref_16))./f_Ref_16)*100)))
ERR_PERC_16=mean((((((f_SG_16-f_Ref_16))./f_Ref_16)*100)))

%% analisi separate: 3.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_30, f_SG_30)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_30,fSG.S1_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_30,fSG.S2_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_30,fSG.S3_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_30,fSG.S4_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_30,fSG.S5_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_30,fSG.S6_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_30,fSG.S7_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_30,fSG.S8_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_30,fSG.S9_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_30,fSG.S10_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_30+1),fitresult(0:max(f_Ref_30+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 3.0 km\cdoth^{-1}')


figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S1_30',fRref.S1_30'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S2_30',fRref.S2_30'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S3_30',fRref.S3_30'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S4_30',fRref.S4_30'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S5_30',fRref.S5_30'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S6_30',fRref.S6_30'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S7_30',fRref.S7_30'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S8_30',fRref.S8_30'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S9_30',fRref.S9_30'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S10_30',fRref.S10_30'], 'c','^')
MOD=mean(f_SG_30-f_Ref_30)
diff=(f_SG_30-f_Ref_30);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{SG}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('3.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(f_Ref_30)+min(f_Ref_30)])

MAE_30=1/length(f_Ref_30)*(sum(abs(f_SG_30-f_Ref_30)))
SE_30=std(abs(f_SG_30-f_Ref_30))/sqrt(length(f_SG_30))
ERR_PERC_30=mean(abs(((((f_SG_30-f_Ref_30))./f_Ref_30)*100)))
ERR_PERC_30=mean((((((f_SG_30-f_Ref_30))./f_Ref_30)*100)))

%% analisi separate: 5.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_50, f_SG_50)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_50,fSG.S1_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_50,fSG.S2_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_50,fSG.S3_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_50,fSG.S4_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_50,fSG.S5_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_50,fSG.S6_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_50,fSG.S7_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_50,fSG.S8_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_50,fSG.S9_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_50,fSG.S10_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_50+1),fitresult(0:max(f_Ref_50+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 5.0 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S1_50',fRref.S1_50'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S2_50',fRref.S2_50'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S3_50',fRref.S3_50'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S4_50',fRref.S4_50'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S5_50',fRref.S5_50'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S6_50',fRref.S6_50'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S7_50',fRref.S7_50'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S8_50',fRref.S8_50'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S9_50',fRref.S9_50'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S10_50',fRref.S10_50'], 'c','^')
MOD=mean(f_SG_50-f_Ref_50)
diff=(f_SG_50-f_Ref_50);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{SG}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('5.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 40])

MAE_50=1/length(f_Ref_50)*(sum(abs(f_SG_50-f_Ref_50)))
SE_50=std(abs(f_SG_50-f_Ref_50))/sqrt(length(f_SG_50))
ERR_PERC_50=mean(abs(((((f_SG_50-f_Ref_50))./f_Ref_50)*100)))
ERR_PERC_50=mean((((((f_SG_50-f_Ref_50))./f_Ref_50)*100)))

%% analisi separate: 6.6 km/h
figure()
[fitresult, gof] = createFit(f_Ref_66, f_SG_66)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_66,fSG.S1_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_66,fSG.S2_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_66,fSG.S3_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_66,fSG.S4_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_66,fSG.S5_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_66,fSG.S6_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_66,fSG.S7_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_66,fSG.S8_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_66,fSG.S9_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_66,fSG.S10_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_66+1),fitresult(0:max(f_Ref_66+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 6.6 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S1_66',fRref.S1_66'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S2_66',fRref.S2_66'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S3_66',fRref.S3_66'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S4_66',fRref.S4_66'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S5_66',fRref.S5_66'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S6_66',fRref.S6_66'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S7_66',fRref.S7_66'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S8_66',fRref.S8_66'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S9_66',fRref.S9_66'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S10_66',fRref.S10_66'], 'c','^')
MOD=mean(-f_Ref_66+f_SG_66)
diff=(-f_Ref_66+f_SG_66);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) 45],[MOD MOD], 'k-','linewidth',2)
plot([a(1) 45],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) 45],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{SG}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('6.6 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[45/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 45])

MAE_66=1/length(f_Ref_66)*(sum(abs(f_SG_66-f_Ref_66)))
SE_66=std(abs(f_SG_66-f_Ref_66))/sqrt(length(f_SG_66))
ERR_PERC_66=mean(abs(((((f_SG_66-f_Ref_66))./f_Ref_66)*100)))
ERR_PERC_66=mean((((((f_SG_66-f_Ref_66))./f_Ref_66)*100)))

%% analisi separate: 8.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_80, f_SG_80)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_80,fSG.S1_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_80,fSG.S2_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_80,fSG.S3_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_80,fSG.S4_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_80,fSG.S5_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_80,fSG.S6_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_80,fSG.S7_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_80,fSG.S8_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_80,fSG.S9_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_80,fSG.S10_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_80+1),fitresult(0:max(f_Ref_80+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 8.0 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S1_80',fRref.S1_80'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S2_80',fRref.S2_80'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S3_80',fRref.S3_80'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S4_80',fRref.S4_80'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S5_80',fRref.S5_80'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S6_80',fRref.S6_80'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S7_80',fRref.S7_80'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S8_80',fRref.S8_80'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S9_80',fRref.S9_80'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fSG.S10_80',fRref.S10_80'], 'c','^')
MOD=mean(-f_Ref_80+f_SG_80)
diff=(-f_Ref_80+f_SG_80);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{SG}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{SG} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('8.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 30])

MAE_80=1/length(f_Ref_80)*(sum(abs(f_SG_80-f_Ref_80)))
SE_80=std(abs(f_SG_80-f_Ref_80))/sqrt(length(f_SG_80))
ERR_PERC_80=mean(abs(((((f_SG_80-f_Ref_80))./f_Ref_80)*100)))
ERR_PERC_80=mean((((((f_SG_80-f_Ref_80))./f_Ref_80)*100)))

%% Breath-by-Breath analysis PCA vs Ref

reference_respiratory_rate_PSD_static=cell2mat(struct2cell(f_reference))
pca_respiratory_rate_PSD_static=cell2mat(struct2cell(f_textile_clean))

[reference_respiratory_rate_PSD_static pca_respiratory_rate_PSD_static pca_respiratory_rate_PSD_static-reference_respiratory_rate_PSD_static]
bar([reference_respiratory_rate_PSD_static pca_respiratory_rate_PSD_static])
legend('f_{R} Hz reference','f_{R} Hz pca')
labels={'S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80'}
xticklabels(labels)


% Analisi atto-atto

f_Ref_16=vertcat(fRref.S1_16',fRref.S2_16',fRref.S3_16',fRref.S4_16',fRref.S5_16',fRref.S6_16',fRref.S7_16',fRref.S8_16',fRref.S9_16',fRref.S10_16')
f_PCA_16=vertcat(fPCA.S1_16',fPCA.S2_16',fPCA.S3_16',fPCA.S4_16',fPCA.S5_16',fPCA.S6_16',fPCA.S7_16',fPCA.S8_16',fPCA.S9_16',fPCA.S10_16')

f_Ref_30=vertcat(fRref.S1_30',fRref.S2_30',fRref.S3_30',fRref.S4_30',fRref.S5_30',fRref.S6_30',fRref.S7_30',fRref.S8_30',fRref.S9_30',fRref.S10_30')
f_PCA_30=vertcat(fPCA.S1_30',fPCA.S2_30',fPCA.S3_30',fPCA.S4_30',fPCA.S5_30',fPCA.S6_30',fPCA.S7_30',fPCA.S8_30',fPCA.S9_30',fPCA.S10_30')

f_Ref_50=vertcat(fRref.S1_50',fRref.S2_50',fRref.S3_50',fRref.S4_50',fRref.S5_50',fRref.S6_50',fRref.S7_50',fRref.S8_50',fRref.S9_50',fRref.S10_50')
f_PCA_50=vertcat(fPCA.S1_50',fPCA.S2_50',fPCA.S3_50',fPCA.S4_50',fPCA.S5_50',fPCA.S6_50',fPCA.S7_50',fPCA.S8_50',fPCA.S9_50',fPCA.S10_50')

f_Ref_66=vertcat(fRref.S1_66',fRref.S2_66',fRref.S3_66',fRref.S4_66',fRref.S5_66',fRref.S6_66',fRref.S7_66',fRref.S8_66',fRref.S9_66',fRref.S10_66')
f_PCA_66=vertcat(fPCA.S1_66',fPCA.S2_66',fPCA.S3_66',fPCA.S4_66',fPCA.S5_66',fPCA.S6_66',fPCA.S7_66',fPCA.S8_66',fPCA.S9_66',fPCA.S10_66')

f_Ref_80=vertcat(fRref.S1_80',fRref.S2_80',fRref.S3_80',fRref.S4_80',fRref.S5_80',fRref.S6_80',fRref.S7_80',fRref.S8_80',fRref.S9_80',fRref.S10_80')
f_PCA_80=vertcat(fPCA.S1_80',fPCA.S2_80',fPCA.S3_80',fPCA.S4_80',fPCA.S5_80',fPCA.S6_80',fPCA.S7_80',fPCA.S8_80',fPCA.S9_80',fPCA.S10_80')


plot(f_Ref_16,f_PCA_16,'o')
hold on
plot(f_Ref_30,f_PCA_30,'o')
plot(f_Ref_50,f_PCA_50,'o')
plot(f_Ref_66,f_PCA_66,'o')
plot(f_Ref_80,f_PCA_80,'o')

%% analisi separate: 1.6 km/h
figure()
[fitresult, gof] = createFit(f_Ref_16, f_PCA_16)
close all
figure('Renderer', 'painters', 'Position', [100 100 500 400])
plot (fRref.S1_16,fPCA.S1_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_16,fPCA.S2_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_16,fPCA.S3_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_16,fPCA.S4_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_16,fPCA.S5_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_16,fPCA.S6_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_16,fPCA.S7_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_16,fPCA.S8_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_16,fPCA.S9_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_16,fPCA.S10_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_16+1),fitresult(0:max(f_Ref_16+1)),'k-.','linewidth',2)
xlabel ('f_{R}[i]|_F [breaths\cdotmin^{-1}]')
ylabel ('f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 1.6 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S1_16',fRref.S1_16'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S2_16',fRref.S2_16'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S3_16',fRref.S3_16'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S4_16',fRref.S4_16'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S5_16',fRref.S5_16'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S6_16',fRref.S6_16'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S7_16',fRref.S7_16'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S8_16',fRref.S8_16'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S9_16',fRref.S9_16'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S10_16',fRref.S10_16'], 'c','^')

MOD=mean(f_PCA_16-f_Ref_16)
diff=(f_PCA_16-f_Ref_16);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('1.6 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(f_Ref_16)+min(f_Ref_16)])

MAE_16=1/length(f_Ref_16)*(sum(abs(f_PCA_16-f_Ref_16)))
SE_16=std(abs(f_PCA_16-f_Ref_16))/sqrt(length(f_PCA_16))
ERR_PERC_16=mean(abs(((((f_PCA_16-f_Ref_16))./f_Ref_16)*100)))
ERR_PERC_16=mean((((((f_PCA_16-f_Ref_16))./f_Ref_16)*100)))

%% analisi separate: 3.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_30, f_PCA_30)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_30,fPCA.S1_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_30,fPCA.S2_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_30,fPCA.S3_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_30,fPCA.S4_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_30,fPCA.S5_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_30,fPCA.S6_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_30,fPCA.S7_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_30,fPCA.S8_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_30,fPCA.S9_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_30,fPCA.S10_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_30+1),fitresult(0:max(f_Ref_30+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 3.0 km\cdoth^{-1}')


figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S1_30',fRref.S1_30'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S2_30',fRref.S2_30'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S3_30',fRref.S3_30'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S4_30',fRref.S4_30'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S5_30',fRref.S5_30'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S6_30',fRref.S6_30'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S7_30',fRref.S7_30'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S8_30',fRref.S8_30'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S9_30',fRref.S9_30'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S10_30',fRref.S10_30'], 'c','^')
MOD=mean(f_PCA_30-f_Ref_30)
diff=(f_PCA_30-f_Ref_30);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('3.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(f_Ref_30)+min(f_Ref_30)])

MAE_30=1/length(f_Ref_30)*(sum(abs(f_PCA_30-f_Ref_30)))
SE_30=std(abs(f_PCA_30-f_Ref_30))/sqrt(length(f_PCA_30))
ERR_PERC_30=mean(abs(((((f_PCA_30-f_Ref_30))./f_Ref_30)*100)))
ERR_PERC_30=mean((((((f_PCA_30-f_Ref_30))./f_Ref_30)*100)))

%% analisi separate: 5.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_50, f_PCA_50)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_50,fPCA.S1_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_50,fPCA.S2_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_50,fPCA.S3_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_50,fPCA.S4_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_50,fPCA.S5_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_50,fPCA.S6_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_50,fPCA.S7_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_50,fPCA.S8_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_50,fPCA.S9_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_50,fPCA.S10_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_50+1),fitresult(0:max(f_Ref_50+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 5.0 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S1_50',fRref.S1_50'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S2_50',fRref.S2_50'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S3_50',fRref.S3_50'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S4_50',fRref.S4_50'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S5_50',fRref.S5_50'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S6_50',fRref.S6_50'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S7_50',fRref.S7_50'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S8_50',fRref.S8_50'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S9_50',fRref.S9_50'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S10_50',fRref.S10_50'], 'c','^')
MOD=mean(f_PCA_50-f_Ref_50)
diff=(f_PCA_50-f_Ref_50);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('5.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 40])

MAE_50=1/length(f_Ref_50)*(sum(abs(f_PCA_50-f_Ref_50)))
SE_50=std(abs(f_PCA_50-f_Ref_50))/sqrt(length(f_PCA_50))
ERR_PERC_50=mean(abs(((((f_PCA_50-f_Ref_50))./f_Ref_50)*100)))
ERR_PERC_50=mean((((((f_PCA_50-f_Ref_50))./f_Ref_50)*100)))

%% analisi separate: 6.6 km/h
figure()
[fitresult, gof] = createFit(f_Ref_66, f_PCA_66)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_66,fPCA.S1_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_66,fPCA.S2_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_66,fPCA.S3_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_66,fPCA.S4_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_66,fPCA.S5_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_66,fPCA.S6_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_66,fPCA.S7_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_66,fPCA.S8_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_66,fPCA.S9_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_66,fPCA.S10_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_66+1),fitresult(0:max(f_Ref_66+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 6.6 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S1_66',fRref.S1_66'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S2_66',fRref.S2_66'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S3_66',fRref.S3_66'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S4_66',fRref.S4_66'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S5_66',fRref.S5_66'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S6_66',fRref.S6_66'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S7_66',fRref.S7_66'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S8_66',fRref.S8_66'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S9_66',fRref.S9_66'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S10_66',fRref.S10_66'], 'c','^')
MOD=mean(-f_Ref_66+f_PCA_66)
diff=(-f_Ref_66+f_PCA_66);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) 45],[MOD MOD], 'k-','linewidth',2)
plot([a(1) 45],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) 45],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('6.6 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[45/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 45])

MAE_66=1/length(f_Ref_66)*(sum(abs(f_PCA_66-f_Ref_66)))
SE_66=std(abs(f_PCA_66-f_Ref_66))/sqrt(length(f_PCA_66))
ERR_PERC_66=mean(abs(((((f_PCA_66-f_Ref_66))./f_Ref_66)*100)))
ERR_PERC_66=mean((((((f_PCA_66-f_Ref_66))./f_Ref_66)*100)))

%% analisi separate: 8.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_80, f_PCA_80)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_80,fPCA.S1_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_80,fPCA.S2_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_80,fPCA.S3_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_80,fPCA.S4_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_80,fPCA.S5_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_80,fPCA.S6_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_80,fPCA.S7_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_80,fPCA.S8_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_80,fPCA.S9_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_80,fPCA.S10_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_80+1),fitresult(0:max(f_Ref_80+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 8.0 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S1_80',fRref.S1_80'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S2_80',fRref.S2_80'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S3_80',fRref.S3_80'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S4_80',fRref.S4_80'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S5_80',fRref.S5_80'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S6_80',fRref.S6_80'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S7_80',fRref.S7_80'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S8_80',fRref.S8_80'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S9_80',fRref.S9_80'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA.S10_80',fRref.S10_80'], 'c','^')
MOD=mean(-f_Ref_80+f_PCA_80)
diff=(-f_Ref_80+f_PCA_80);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('8.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 30])

MAE_80=1/length(f_Ref_80)*(sum(abs(f_PCA_80-f_Ref_80)))
SE_80=std(abs(f_PCA_80-f_Ref_80))/sqrt(length(f_PCA_80))
ERR_PERC_80=mean(abs(((((f_PCA_80-f_Ref_80))./f_Ref_80)*100)))
ERR_PERC_80=mean((((((f_PCA_80-f_Ref_80))./f_Ref_80)*100)))

%% Breath-by-Breath analysis PCA_nonred vs Ref

reference_respiratory_rate_PSD_static=cell2mat(struct2cell(f_reference))
pca_nonred_respiratory_rate_PSD_static=cell2mat(struct2cell(f_textile_nonred))

[reference_respiratory_rate_PSD_static pca_nonred_respiratory_rate_PSD_static pca_nonred_respiratory_rate_PSD_static-reference_respiratory_rate_PSD_static]
bar([reference_respiratory_rate_PSD_static pca_nonred_respiratory_rate_PSD_static])
legend('f_{R} Hz reference','f_{R} Hz pca')
labels={'S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80','S1_16','S1_30','S1_50','S1_66','S1_80'}
xticklabels(labels)


% Analisi atto-atto

f_Ref_16=vertcat(fRref.S1_16',fRref.S2_16',fRref.S3_16',fRref.S4_16',fRref.S5_16',fRref.S6_16',fRref.S7_16',fRref.S8_16',fRref.S9_16',fRref.S10_16')
f_PCA_nonred_16=vertcat(fPCA_nonred.S1_16',fPCA_nonred.S2_16',fPCA_nonred.S3_16',fPCA_nonred.S4_16',fPCA_nonred.S5_16',fPCA_nonred.S6_16',fPCA_nonred.S7_16',fPCA_nonred.S8_16',fPCA_nonred.S9_16',fPCA_nonred.S10_16')

f_Ref_30=vertcat(fRref.S1_30',fRref.S2_30',fRref.S3_30',fRref.S4_30',fRref.S5_30',fRref.S6_30',fRref.S7_30',fRref.S8_30',fRref.S9_30',fRref.S10_30')
f_PCA_nonred_30=vertcat(fPCA_nonred.S1_30',fPCA_nonred.S2_30',fPCA_nonred.S3_30',fPCA_nonred.S4_30',fPCA_nonred.S5_30',fPCA_nonred.S6_30',fPCA_nonred.S7_30',fPCA_nonred.S8_30',fPCA_nonred.S9_30',fPCA_nonred.S10_30')

f_Ref_50=vertcat(fRref.S1_50',fRref.S2_50',fRref.S3_50',fRref.S4_50',fRref.S5_50',fRref.S6_50',fRref.S7_50',fRref.S8_50',fRref.S9_50',fRref.S10_50')
f_PCA_nonred_50=vertcat(fPCA_nonred.S1_50',fPCA_nonred.S2_50',fPCA_nonred.S3_50',fPCA_nonred.S4_50',fPCA_nonred.S5_50',fPCA_nonred.S6_50',fPCA_nonred.S7_50',fPCA_nonred.S8_50',fPCA_nonred.S9_50',fPCA_nonred.S10_50')

f_Ref_66=vertcat(fRref.S1_66',fRref.S2_66',fRref.S3_66',fRref.S4_66',fRref.S5_66',fRref.S6_66',fRref.S7_66',fRref.S8_66',fRref.S9_66',fRref.S10_66')
f_PCA_nonred_66=vertcat(fPCA_nonred.S1_66',fPCA_nonred.S2_66',fPCA_nonred.S3_66',fPCA_nonred.S4_66',fPCA_nonred.S5_66',fPCA_nonred.S6_66',fPCA_nonred.S7_66',fPCA_nonred.S8_66',fPCA_nonred.S9_66',fPCA_nonred.S10_66')

f_Ref_80=vertcat(fRref.S1_80',fRref.S2_80',fRref.S3_80',fRref.S4_80',fRref.S5_80',fRref.S6_80',fRref.S7_80',fRref.S8_80',fRref.S9_80',fRref.S10_80')
f_PCA_nonred_80=vertcat(fPCA_nonred.S1_80',fPCA_nonred.S2_80',fPCA_nonred.S3_80',fPCA_nonred.S4_80',fPCA_nonred.S5_80',fPCA_nonred.S6_80',fPCA_nonred.S7_80',fPCA_nonred.S8_80',fPCA_nonred.S9_80',fPCA_nonred.S10_80')


plot(f_Ref_16,f_PCA_nonred_16,'o')
hold on
plot(f_Ref_30,f_PCA_nonred_30,'o')
plot(f_Ref_50,f_PCA_nonred_50,'o')
plot(f_Ref_66,f_PCA_nonred_66,'o')
plot(f_Ref_80,f_PCA_nonred_80,'o')

%% analisi separate: 1.6 km/h
figure()
[fitresult, gof] = createFit(f_Ref_16, f_PCA_nonred_16)
close all
figure('Renderer', 'painters', 'Position', [100 100 500 400])
plot (fRref.S1_16,fPCA_nonred.S1_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_16,fPCA_nonred.S2_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_16,fPCA_nonred.S3_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_16,fPCA_nonred.S4_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_16,fPCA_nonred.S5_16, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_16,fPCA_nonred.S6_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_16,fPCA_nonred.S7_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_16,fPCA_nonred.S8_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_16,fPCA_nonred.S9_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_16,fPCA_nonred.S10_16, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_16+1),fitresult(0:max(f_Ref_16+1)),'k-.','linewidth',2)
xlabel ('f_{R}[i]|_F [breaths\cdotmin^{-1}]')
ylabel ('f_{R}[i]|_{PCA_nonred} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 1.6 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S1_16',fRref.S1_16'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S2_16',fRref.S2_16'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S3_16',fRref.S3_16'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S4_16',fRref.S4_16'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S5_16',fRref.S5_16'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S6_16',fRref.S6_16'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S7_16',fRref.S7_16'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S8_16',fRref.S8_16'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S9_16',fRref.S9_16'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S10_16',fRref.S10_16'], 'c','^')

MOD=mean(f_PCA_nonred_16-f_Ref_16)
diff=(f_PCA_nonred_16-f_Ref_16);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA_nonred}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA_nonred} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('1.6 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(f_Ref_16)+min(f_Ref_16)])

MAE_16=1/length(f_Ref_16)*(sum(abs(f_PCA_nonred_16-f_Ref_16)))
SE_16=std(abs(f_PCA_nonred_16-f_Ref_16))/sqrt(length(f_PCA_nonred_16))
ERR_PERC_16=mean(abs(((((f_PCA_nonred_16-f_Ref_16))./f_Ref_16)*100)))
ERR_PERC_16=mean((((((f_PCA_nonred_16-f_Ref_16))./f_Ref_16)*100)))

%% analisi separate: 3.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_30, f_PCA_nonred_30)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_30,fPCA_nonred.S1_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_30,fPCA_nonred.S2_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_30,fPCA_nonred.S3_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_30,fPCA_nonred.S4_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_30,fPCA_nonred.S5_30, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_30,fPCA_nonred.S6_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_30,fPCA_nonred.S7_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_30,fPCA_nonred.S8_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_30,fPCA_nonred.S9_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_30,fPCA_nonred.S10_30, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_30+1),fitresult(0:max(f_Ref_30+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA_nonred}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 3.0 km\cdoth^{-1}')


figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S1_30',fRref.S1_30'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S2_30',fRref.S2_30'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S3_30',fRref.S3_30'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S4_30',fRref.S4_30'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S5_30',fRref.S5_30'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S6_30',fRref.S6_30'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S7_30',fRref.S7_30'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S8_30',fRref.S8_30'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S9_30',fRref.S9_30'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S10_30',fRref.S10_30'], 'c','^')
MOD=mean(f_PCA_nonred_30-f_Ref_30)
diff=(f_PCA_nonred_30-f_Ref_30);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA_nonred}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA_nonred} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('3.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(f_Ref_30)+min(f_Ref_30)])

MAE_30=1/length(f_Ref_30)*(sum(abs(f_PCA_nonred_30-f_Ref_30)))
SE_30=std(abs(f_PCA_nonred_30-f_Ref_30))/sqrt(length(f_PCA_nonred_30))
ERR_PERC_30=mean(abs(((((f_PCA_nonred_30-f_Ref_30))./f_Ref_30)*100)))
ERR_PERC_30=mean((((((f_PCA_nonred_30-f_Ref_30))./f_Ref_30)*100)))

%% analisi separate: 5.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_50, f_PCA_nonred_50)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_50,fPCA_nonred.S1_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_50,fPCA_nonred.S2_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_50,fPCA_nonred.S3_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_50,fPCA_nonred.S4_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_50,fPCA_nonred.S5_50, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_50,fPCA_nonred.S6_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_50,fPCA_nonred.S7_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_50,fPCA_nonred.S8_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_50,fPCA_nonred.S9_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_50,fPCA_nonred.S10_50, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_50+1),fitresult(0:max(f_Ref_50+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA_nonred}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 5.0 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S1_50',fRref.S1_50'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S2_50',fRref.S2_50'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S3_50',fRref.S3_50'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S4_50',fRref.S4_50'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S5_50',fRref.S5_50'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S6_50',fRref.S6_50'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S7_50',fRref.S7_50'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S8_50',fRref.S8_50'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S9_50',fRref.S9_50'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S10_50',fRref.S10_50'], 'c','^')
MOD=mean(f_PCA_nonred_50-f_Ref_50)
diff=(f_PCA_nonred_50-f_Ref_50);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA_nonred}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA_nonred} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('5.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 40])

MAE_50=1/length(f_Ref_50)*(sum(abs(f_PCA_nonred_50-f_Ref_50)))
SE_50=std(abs(f_PCA_nonred_50-f_Ref_50))/sqrt(length(f_PCA_nonred_50))
ERR_PERC_50=mean(abs(((((f_PCA_nonred_50-f_Ref_50))./f_Ref_50)*100)))
ERR_PERC_50=mean((((((f_PCA_nonred_50-f_Ref_50))./f_Ref_50)*100)))

%% analisi separate: 6.6 km/h
figure()
[fitresult, gof] = createFit(f_Ref_66, f_PCA_nonred_66)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_66,fPCA_nonred.S1_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_66,fPCA_nonred.S2_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_66,fPCA_nonred.S3_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_66,fPCA_nonred.S4_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_66,fPCA_nonred.S5_66, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_66,fPCA_nonred.S6_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_66,fPCA_nonred.S7_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_66,fPCA_nonred.S8_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_66,fPCA_nonred.S9_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_66,fPCA_nonred.S10_66, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_66+1),fitresult(0:max(f_Ref_66+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA_nonred}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 6.6 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S1_66',fRref.S1_66'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S2_66',fRref.S2_66'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S3_66',fRref.S3_66'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S4_66',fRref.S4_66'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S5_66',fRref.S5_66'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S6_66',fRref.S6_66'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S7_66',fRref.S7_66'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S8_66',fRref.S8_66'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S9_66',fRref.S9_66'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S10_66',fRref.S10_66'], 'c','^')
MOD=mean(-f_Ref_66+f_PCA_nonred_66)
diff=(-f_Ref_66+f_PCA_nonred_66);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) 45],[MOD MOD], 'k-','linewidth',2)
plot([a(1) 45],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) 45],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA_nonred}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA_nonred} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('6.6 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[45/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 45])

MAE_66=1/length(f_Ref_66)*(sum(abs(f_PCA_nonred_66-f_Ref_66)))
SE_66=std(abs(f_PCA_nonred_66-f_Ref_66))/sqrt(length(f_PCA_nonred_66))
ERR_PERC_66=mean(abs(((((f_PCA_nonred_66-f_Ref_66))./f_Ref_66)*100)))
ERR_PERC_66=mean((((((f_PCA_nonred_66-f_Ref_66))./f_Ref_66)*100)))

%% analisi separate: 8.0 km/h
figure()
[fitresult, gof] = createFit(f_Ref_80, f_PCA_nonred_80)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (fRref.S1_80,fPCA_nonred.S1_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (fRref.S2_80,fPCA_nonred.S2_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S3_80,fPCA_nonred.S3_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S4_80,fPCA_nonred.S4_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S5_80,fPCA_nonred.S5_80, 'ko','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot (fRref.S6_80,fPCA_nonred.S6_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k');
plot (fRref.S7_80,fPCA_nonred.S7_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (fRref.S8_80,fPCA_nonred.S8_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (fRref.S9_80,fPCA_nonred.S9_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (fRref.S10_80,fPCA_nonred.S10_80, 'k^','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')
plot(0:max(f_Ref_80+1),fitresult(0:max(f_Ref_80+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{PCA_nonred}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10')
legend off
a=get(gca,'xlim')
title('Correlation analysis - 8.0 km\cdoth^{-1}')
figure('Renderer', 'painters', 'Position', [100 100 600 350])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S1_80',fRref.S1_80'], 'k','o')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S2_80',fRref.S2_80'], 'b','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S3_80',fRref.S3_80'], 'm','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S4_80',fRref.S4_80'], 'r','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S5_80',fRref.S5_80'], 'c','o')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S6_80',fRref.S6_80'], 'k','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S7_80',fRref.S7_80'], 'b','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S8_80',fRref.S8_80'], 'm','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S9_80',fRref.S9_80'], 'r','^')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [fPCA_nonred.S10_80',fRref.S10_80'], 'c','^')
MOD=mean(-f_Ref_80+f_PCA_nonred_80)
diff=(-f_Ref_80+f_PCA_nonred_80);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
% xlabel('1/2\cdot(f_{R}[i]|_F + f_{R}[i]|_{PCA_nonred}) [breaths\cdotmin^{-1}]')
% ylabel('f_{R}[i]|_F-f_{R}[i]|_{PCA_nonred} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('8.0 km\cdoth^{-1}')
set(get(gca,'title'),'Position',[a(2)/2 8.5 0])
legend('Vol. 1','Vol. 2','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','Location','NorthEastOutside')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 30])

MAE_80=1/length(f_Ref_80)*(sum(abs(f_PCA_nonred_80-f_Ref_80)))
SE_80=std(abs(f_PCA_nonred_80-f_Ref_80))/sqrt(length(f_PCA_nonred_80))
ERR_PERC_80=mean(abs(((((f_PCA_nonred_80-f_Ref_80))./f_Ref_80)*100)))
ERR_PERC_80=mean((((((f_PCA_nonred_80-f_Ref_80))./f_Ref_80)*100)))


%% Tutti insieme SG vs REF tutti insieme

f_Ref_16=vertcat(fRref.S1_16',fRref.S2_16',fRref.S3_16',fRref.S4_16',fRref.S5_16',fRref.S6_16',fRref.S7_16',fRref.S8_16',fRref.S9_16',fRref.S10_16')
f_SG_16=vertcat(fSG.S1_16',fSG.S2_16',fSG.S3_16',fSG.S4_16',fSG.S5_16',fSG.S6_16',fSG.S7_16',fSG.S8_16',fSG.S9_16',fSG.S10_16')

f_Ref_30=vertcat(fRref.S1_30',fRref.S2_30',fRref.S3_30',fRref.S4_30',fRref.S5_30',fRref.S6_30',fRref.S7_30',fRref.S8_30',fRref.S9_30',fRref.S10_30')
f_SG_30=vertcat(fSG.S1_30',fSG.S2_30',fSG.S3_30',fSG.S4_30',fSG.S5_30',fSG.S6_30',fSG.S7_30',fSG.S8_30',fSG.S9_30',fSG.S10_30')

f_Ref_50=vertcat(fRref.S1_50',fRref.S2_50',fRref.S3_50',fRref.S4_50',fRref.S5_50',fRref.S6_50',fRref.S7_50',fRref.S8_50',fRref.S9_50',fRref.S10_50')
f_SG_50=vertcat(fSG.S1_50',fSG.S2_50',fSG.S3_50',fSG.S4_50',fSG.S5_50',fSG.S6_50',fSG.S7_50',fSG.S8_50',fSG.S9_50',fSG.S10_50')

f_Ref_66=vertcat(fRref.S1_66',fRref.S2_66',fRref.S3_66',fRref.S4_66',fRref.S5_66',fRref.S6_66',fRref.S7_66',fRref.S8_66',fRref.S9_66',fRref.S10_66')
f_SG_66=vertcat(fSG.S1_66',fSG.S2_66',fSG.S3_66',fSG.S4_66',fSG.S5_66',fSG.S6_66',fSG.S7_66',fSG.S8_66',fSG.S9_66',fSG.S10_66')

f_Ref_80=vertcat(fRref.S1_80',fRref.S2_80',fRref.S3_80',fRref.S4_80',fRref.S5_80',fRref.S6_80',fRref.S7_80',fRref.S8_80',fRref.S9_80',fRref.S10_80')
f_SG_80=vertcat(fSG.S1_80',fSG.S2_80',fSG.S3_80',fSG.S4_80',fSG.S5_80',fSG.S6_80',fSG.S7_80',fSG.S8_80',fSG.S9_80',fSG.S10_80')

TUTTIINSIEME_REF=vertcat(f_Ref_16,f_Ref_30,f_Ref_50,f_Ref_66,f_Ref_80);
TUTTIINSIEME_SG=vertcat(f_SG_16,f_SG_30,f_SG_50,f_SG_66,f_SG_80);


figure()
[fitresult, gof] = createFit(TUTTIINSIEME_REF, TUTTIINSIEME_SG)
close all
figure('Renderer', 'painters', 'Position', [100 100 400 400])
plot (f_Ref_16,f_SG_16, 'kv','MarkerSize',6,'linewidth',1,'MarkerFaceColor','k'); hold on;
plot (f_Ref_30,f_SG_30, 'kv','MarkerSize',6,'linewidth',1,'MarkerFaceColor','b')
plot (f_Ref_50,f_SG_50, 'kv','MarkerSize',6,'linewidth',1,'MarkerFaceColor','m')
plot (f_Ref_66,f_SG_66, 'kv','MarkerSize',6,'linewidth',1,'MarkerFaceColor','r')
plot (f_Ref_80,f_SG_80, 'kv','MarkerSize',6,'linewidth',1,'MarkerFaceColor','c')

plot(0:max(TUTTIINSIEME_REF+1),fitresult(0:max(TUTTIINSIEME_REF+1)),'k-.','linewidth',2)
xlabel ('f_{R_{F}} [breaths\cdotmin^{-1}]')
ylabel ('f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
legend('1.6 km\cdoth^{-1}','3.0 km\cdoth^{-1}','5.0 km\cdoth^{-1}','6.6 km\cdoth^{-1}','8.0 km\cdoth^{-1}')
legend off
a=get(gca,'xlim')
title('Correlation analysis')
figure('Renderer', 'painters', 'Position', [100 100 500 300])
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [f_Ref_16,f_SG_16], 'k','v')
hold on
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [f_Ref_30,f_SG_30], 'b','v')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [f_Ref_50,f_SG_50], 'm','v')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [f_Ref_66,f_SG_66], 'r','v')
[ media_vett, diff, mod, loa1, loa2, amp_loa] = Bland( [f_Ref_80,f_SG_80], 'c','v')

MOD=mean(TUTTIINSIEME_REF-TUTTIINSIEME_SG)
diff=(TUTTIINSIEME_REF-TUTTIINSIEME_SG);
loa1=MOD+(1.96*std(diff));
loa2=MOD-(1.96*std(diff));
plot([a(1) a(2)],[MOD MOD], 'k-','linewidth',2)
plot([a(1) a(2)],[loa1 loa1], 'r-','linewidth',2)
plot([a(1) a(2)],[loa2 loa2], 'r-','linewidth',2)
xlabel('1/2\cdot(f_{R_{F}} + f_{R_{SG}} [breaths\cdotmin^{-1}]')
ylabel('f_{R_{F}}-f_{R_{SG}} [breaths\cdotmin^{-1}]')
set(gca,'FontSize',14)
title('Bland Altman analysis')
legend('1.6 km\cdoth^{-1}','3.0 km\cdoth^{-1}','5.0 km\cdoth^{-1}','6.6 km\cdoth^{-1}','8.0 km\cdoth^{-1}')
xlim([a(1) a(2)])
delta=(loa1-loa2)/2
ylim([-10 10])
xlim([0 max(TUTTIINSIEME_REF)+min(TUTTIINSIEME_REF)])

MAE_ALL=1/length(TUTTIINSIEME_REF)*(sum(abs(TUTTIINSIEME_SG-TUTTIINSIEME_REF)))
SE_ALL=std(abs(TUTTIINSIEME_SG-TUTTIINSIEME_REF))/sqrt(length(TUTTIINSIEME_SG))
ERR_PERC_ALL=mean(abs(((((TUTTIINSIEME_SG-TUTTIINSIEME_REF))./TUTTIINSIEME_REF)*100)))