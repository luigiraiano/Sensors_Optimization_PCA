function subj = Elab_data_Textile_Breathing_MetroInd20_v2(subj_dir_path)
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
    tmp = subj_tmp_file_name_info{1,1}{2};
    
    speed_string = ['data_',strrep(tmp,'.mat','')];
    speed = str2double(strrep(tmp,'.mat',''));
    
    subj.id = subj_id;
    
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processing...']);
    
    
    load(subj_tmp_file);
    
    %% Rename variables
    % Segnali registrati dei 6 piezo posizionati sulla maglia (3+3)
    piezo_maglia = segnale_textile_RT_W;
    time_piezo = tempo_textile_RT_W;
    % Segnale spirometro di riferimento
    spirometro_ref = segnale_spiro_RT_W';
    time_gyro = tempo_IMUG_RT_W;
    % Segnali gyroscope -> asse y parallelo alla gravità
    gyro =  sign_filtimuG_W;
    % Accelerometer
    acc = sign_filtimu_W;
    time_acc = tempo_IMU_RT_W;
    
    
    srate = 250; % Hz
    
    subj.(speed_string).speed = speed/10; % [km/h]
    subj.(speed_string).srate = srate;
    
    % textile
    subj.(speed_string).data.textile_raw = piezo_maglia;
    subj.(speed_string).data.time_textile = time_piezo;
    
    %IMU data
    subj.(speed_string).data.acc = acc;
    subj.(speed_string).data.time_acc = time_acc;
    subj.(speed_string).data.gyro = gyro;
    subj.(speed_string).data.time_gyro = time_gyro;
    
    % Spirometro
    subj.(speed_string).data.spirometro_ref = spirometro_ref;
    %% 1st Assessment - Sensor Space
    subj.(speed_string).data.elab.info1 = "/******** 1st Assessment ********/";
    % Use all sensors to evaluate the average
    subj.(speed_string).data.elab.piezo_maglia_ave1 = mean(piezo_maglia,2);
    % Evaluate PSD of the ave signal
    [subj.(speed_string).data.elab.P_norm_ave1, subj.(speed_string).data.elab.freq_ave1,...
        subj.(speed_string).data.elab.P_ave1, subj.(speed_string).data.elab.f_peaks_ave1] =...
        Perform_PSD_v1(subj.(speed_string).data.elab.piezo_maglia_ave1,srate);
    % Evaluate PSD of the reference signal
    [subj.(speed_string).data.elab.P_norm_spiro, subj.(speed_string).data.elab.freq_spiro,...
        subj.(speed_string).data.elab.P_spiro, subj.(speed_string).data.elab.f_peaks_spiro] =...
        Perform_PSD_v1(spirometro_ref,srate);
    
    %%
    % reference signal
    subj.(speed_string).data.spirometer_ref = spirometro_ref;
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
    
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
end % end for i subj_data

end % end function