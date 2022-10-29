%% Luigi Raiano, v1, 17-03-2020
%%
% How to read variables
%
% FLUSSIMETRO
%
% Raw data
% 	tempo_spiro, segnale_spiro
%
% Segnale integrato e ritagliato (60s) ma non filtrato
% 	tempo_spiro_RT_W, segnale_spiro_RT_W
%
%
% MAGLIA
% Raw data
% 	tempo_textile, segnale_textile
%
% Segnale ritagliato (60 s) ma non filtrato
% 	tempo_textile_RT_W, segnale_textile_RT_W
%
% ACCEL GYRO (non contenuti nei dati statica)
% Raw data
% 	Accel	tempo_acc, segnaleacc
% 	Gyro	tempo_gyro, segnalegyro
%
% Segnale ritagliato (60 s) ma non filtrato
% 	Accel 	tempo_IMU_RT_W, segnale_IMU_RT_W
% 	Gyro 	tempo_IMUG_RT_W, segnale_IMUG_RT_W
%
% /******* Nome file mat *******/
% ABCD
% -> A: iniziale nome;
% -> B: iniziale cognome;
% -> CD: speed (00, 16, 30, 50, 66, 80) [(1e-1) * km/h]
% 
% /******* NB *******/
% Questa funzione non carica i dati IMU in quanto nelle prove statiche
% questi non sono salvati. Inoltre, questi dati sono sovracampionati a 250
% Hz (partendo da circa 20 Hz) e pertanto ricchi di componenti in frequenza
% non legati al movimento ma bensì a rumore.
%%
function subj_struct = SensorsOptimizationPCA_LoadDataNoIMU_v1(subj_dir_path)
%% Get all data available for the subject
subj_data_all = [];
subj_data_all = dir(subj_dir_path);
count = 1;
for i = 1 :length(subj_data_all)
    if(~subj_data_all(i).isdir && ~strcmp(subj_data_all(i).name(1), '.'))
        subj_data{count} = subj_data_all(i).name;
        count = count + 1;
    end % end if
end % end for i
%% read each data file of the subject and save only needed data
for i=1:length(subj_data)
    subj_tmp_file = [];
    subj_tmp_file_name = subj_data{i};
    subj_tmp_file = [subj_dir_path,filesep,subj_tmp_file_name];
    
    subj_tmp_file_name_info = textscan(subj_tmp_file_name,'%s','delimiter','_');
    subj_id = subj_tmp_file_name_info{1,1}{1};
    subj_name = subj_id(1:2);
    subj_speed = subj_id(3:4);
    
    subj_struct.id = subj_name;
    
    disp(['Subj: ',subj_name,' - Speed: ',subj_speed,' Processing...']);
    
    load(subj_tmp_file,'tempo_spiro','segnale_spiro',...
        'tempo_textile', 'segnale_textile',...
        'tempo_spiro_RT_W', 'segnale_spiro_RT_W',...
        'tempo_textile_RT_W', 'segnale_textile_RT_W');
    
    %% Raw data (before segmentation) -> After having checked, RT_W data are already band-pass filtered!!!!
    % Since static data do not have imu, such data are not stored
    subj_struct.data.(['speed_',subj_speed]).raw.tempo_spiro = tempo_spiro; % [s]
    subj_struct.data.(['speed_',subj_speed]).raw.segnale_spiro = segnale_spiro; % [V]
    
    subj_struct.data.(['speed_',subj_speed]).raw.tempo_textile = tempo_textile; % [s]
    subj_struct.data.(['speed_',subj_speed]).raw.segnale_textile = segnale_textile; % [V]
    %% Raw data (after segmentation - window: 60 secs)
    % Since static data do not have imu, such data are not stored
    subj_struct.data.(['speed_',subj_speed]).raw_seg.tempo_spiro = tempo_spiro_RT_W; % [s]
    subj_struct.data.(['speed_',subj_speed]).raw_seg.segnale_spiro = segnale_spiro_RT_W; % [V]
    
    subj_struct.data.(['speed_',subj_speed]).raw_seg.tempo_textile = tempo_textile_RT_W; % [s]
    subj_struct.data.(['speed_',subj_speed]).raw_seg.segnale_textile = segnale_textile_RT_W; % [V]
    %%
    clear tempo_spiro segnale_spiro...
        tempo_textile segnale_textile...
        tempo_spiro_RT_W segnale_spiro_RT_W...
        tempo_textile_RT_W segnale_textile_RT_W
end % end for i
end