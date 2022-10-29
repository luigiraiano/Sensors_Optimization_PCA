function subj = Elab_data_Textile_Breathing_TesiGiuseppe_v1(subj_dir_path,subjs_dir_name,explained_perc_thres,perce_sensors_weigth_thres,corr_thresh)
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
    piezo_maglia = segnale_textile_RT_Filt_W_6segnali;
    % Segnale spirometro di riferimento
    spirometro_ref = segnale_spiro_RT_W';
    % Segnali gyroscope -> asse y parallelo alla gravità
    gyro =  sign_filtimuG_W;
    % Accelerometer
    acc = tempo_IMU_RT_W;
    
    srate = 250; % Hz
    
    subj.(speed_string).speed = speed/10; % [km/h]
    subj.(speed_string).srate = srate;
    
    % textile
    subj.(speed_string).data.textile_raw = piezo_maglia;
    
    %IMU data
    subj.(speed_string).data.acc = acc;
    subj.(speed_string).data.gyro = gyro;
    
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
    %% Clean data - Approach 1: use Torso artefact removal
    subj.(speed_string).data.elab.info2 = "/******** Clean data - Approach 1: use Torso artefact removal ********/";
    subj.(speed_string).data.elab.freq_toarx_rotation = [];
    for i=1:size(piezo_maglia,2)
        [piezo_maglia_noTorso(:,i), freq_toarx_rotation(i)]...
            = Remove_Gyro_Artifact_v2(piezo_maglia(:,i)',gyro(:,2),srate);
    end % end for i
    subj.(speed_string).data.elab.piezo_maglia_noTorso = piezo_maglia_noTorso;
    subj.(speed_string).data.elab.freq_toarx_rotation = freq_toarx_rotation;
    
    piezo_maglia_noTorso_ave = mean(piezo_maglia_noTorso,2);
    subj.(speed_string).data.elab.piezo_maglia_noTorso_ave = piezo_maglia_noTorso_ave;
    %% Clean data - Approach 2: use ICA
    % Run ICA by means RobustICA algorithm (zarzoso et al 2010)
    % ronbustica wants n_signals X n_samples matrices
    % ICA is run without reducing the dimensionality
    subj.(speed_string).data.elab.info3 = "/******** Clean data - Approach 2: use ICA ********/";
    [IC, H, iter, magnification] = Run_ICA_v2(piezo_maglia');
    subj.(speed_string).data.elab.IC = IC;
    subj.(speed_string).data.elab.H = H;
    
    % Select component to keep
    for i=1:size(IC,1)
        [subj.(speed_string).data.elab.P_norm_comps(i,:), subj.(speed_string).data.elab.freq_comps(i,:),...
            subj.(speed_string).data.elab.P_comps(i,:),...
            subj.(speed_string).data.elab.f_peaks_comps.(['comp_',num2str(i)])]...
            = Perform_PSD_v1(IC(i,:),srate);
        
        comps_discarded(i) = Discard_ICs_v1(subj.(speed_string).data.elab.freq_comps(i,:),subj.(speed_string).data.elab.P_norm_comps(i,:));
    end % end for i
    
    % Reconstruct signals
    selectedICs=find(comps_discarded==0);
    subj.(speed_string).data.elab.selectedICs = selectedICs;
    piezo_maglia_ICArec = Clean_With_ICs_v3(IC,H,selectedICs,magnification);
    subj.(speed_string).data.elab.piezo_maglia_ICArec = piezo_maglia_ICArec;
    
    piezo_maglia_ICArec_ave = mean(piezo_maglia_ICArec,2);
    subj.(speed_string).data.elab.piezo_maglia_ICArec_ave = piezo_maglia_ICArec_ave;
    %% Assessment 2: comparison between clening approach 1 and cleaning approach 2
    subj.(speed_string).data.elab.info4 = "/******** Assessment 2: comparison between clening approach 1 and cleaning approach 2 ********/";
    [subj.(speed_string).data.elab.P_norm_aveNoTorso, subj.(speed_string).data.elab.freq_aveNoTorso,...
        subj.(speed_string).data.elab.P_aveNoTorso, subj.(speed_string).data.elab.f_peaks_aveNoTorso]...
        = Perform_PSD_v1(piezo_maglia_noTorso_ave,srate);
    
    [subj.(speed_string).data.elab.P_norm_aveICArec, subj.(speed_string).data.elab.freq_aveICArec,...
        subj.(speed_string).data.elab.P_aveICArec, subj.(speed_string).data.elab.f_peaks_aveICArec]...
        = Perform_PSD_v1(piezo_maglia_ICArec_ave,srate);
    %%
    % reference signal
    subj.(speed_string).data.spirometer_ref = spirometro_ref;
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
    
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
end % end for i subj_data

end % end function