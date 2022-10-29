%% Luigi Raiano, v1, 23/10/2019
% Questa funzione serve a risalvare i file mat contente i dati di
% respirazione registrati con piezo in modo da salavre solo quello usato
% nell'ica con run_ICA_v2. Non salava i dati mimu.
% I file risalvati presentano il seguente format:
% NOME_SPEED.mat
% se SPEED = 0 -> si intende la prova statica
%
% subj_dir_path = subj_dir_path;
% new_main_folder = main_dir_new;
% subj_name = subjs_dir_name{end};
%%
function Get_Subj_Data_v1(subj_dir_path,new_main_folder,subj_name)
%%
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
    
    % load and then clear all except the variables needed fo the code.
    % better in a function
    load(subj_tmp_file);
    
    [b,a]=butter(3,[0.05,2]/(250/2),'bandpass');
    
    if( strcmp( subj_tmp_file_name_info{1,1}{1,1}(1:2), subj_name ) )% mi serve a capire se si tratta della prova statica
        name_ending = subj_tmp_file_name_info{1,1}{6,1};
        
        speed = strrep(name_ending,'.mat','');
        
        
        % band pass filter piezo data
        
        if(~exist('segnale_textile_RT_Filt_W_6segnali')) % subj CT non li ha
            segnale_textile_RT_Filt_W_6segnali = filtfilt(b,a,segnale_textile_RT_W);
        end % end if
        
    elseif( strcmp( subj_tmp_file_name_info{1,1}{1,1}(1:2), lower(subj_name) ) ) % qui ci vanno i dati statistci
        speed = '00';
        
        segnale_textile_RT_Filt_W_6segnali = filtfilt(b,a,segnale_textile_RT_W);
        

    end % end if
    
    subj_new_file = [new_main_folder,filesep,subj_name,filesep,subj_name,'_',speed,'.mat'];
    if(exist([new_main_folder,filesep,subj_name])~=7) % create new folder if it does not exist
        mkdir([new_main_folder,filesep,subj_name]);
    end
    
    % Save textile,time, spiro
%     save(subj_new_file,'segnale_textile_RT_Filt_W_6segnali','segnale_spiro_RT_W','tempo_textile_RT_W');
    
% Save textile,time, spiro, acc, time, gyro, time ----> NB: non tutti i
% sogetti hanno imu!
    save(subj_new_file,'segnale_textile_RT_Filt_W_6segnali','segnale_textile_RT_W','segnale_spiro_RT_W','tempo_textile_RT_W','sign_filtimuG_W','tempo_IMUG_RT_W','sign_filtimu_W','tempo_IMU_RT_W','segnaleacc','segnalegyro');
    disp(['Subj: ',subj_name,' - data stored in ',subj_new_file]);
    
        
    clearvars -except subj_dir_path new_main_folder subj_name subj_data i
    disp(['Subj: ',subj_name,' - data deleted']);
end %% end for i
end