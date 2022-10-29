function subj = Elab_data_Textile_Breathing_v3(subj_dir_path,subjs_dir_name,explained_perc_thres,perce_sensors_weigth_thres)
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
    %% Run PCA
    % input function must be n_samples X n_observations
    % coeff is a matrix so that: score = zscore(X)*coeff -> coeff is a
    % n_sensors X n_principalComponents matrix
    subj.(speed_string).data.elab.info4 = "/******** Run PCA ********/";
    % Run PCA on signal cleaned with torso artefact removal
    [coeff_noTorso,score_noTorso,latent_noTorso,tsquared_noTorso,explained_noTorso,mu_noTorso] = pca(zscore(piezo_maglia_noTorso));
    subj.(speed_string).data.elab.coeff_noTorso = coeff_noTorso;
    subj.(speed_string).data.elab.score_noTorso = score_noTorso;
    % Run PCA on signal cleaned with ICA
    [coeff_ICArec,score_ICArec,latent_ICArec,tsquared_ICArec,explained_ICArec,mu_ICArec] = pca(zscore(piezo_maglia_ICArec));
    subj.(speed_string).data.elab.coeff_ICArec = coeff_ICArec;
    subj.(speed_string).data.elab.score_ICArec = score_ICArec;
    
    subj.(speed_string).data.elab.info5 = "/******** Run PCA - Get components that explain the 95% of the signal ********/";
    % prendi le componenti che esprimono il 95% del segnale, in quelli toglie
    % quelli che hanno un peso inferiore al alpha%
    sum_explained_noTorso = 0;
    idx_noTorso = 0;
    while sum_explained_noTorso <= explained_perc_thres
        idx_noTorso = idx_noTorso + 1;
        sum_explained_noTorso = sum_explained_noTorso + explained_noTorso(idx_noTorso);
    end
    subj.(speed_string).data.elab.numbers_of_PCs_selected_noTorso = idx_noTorso;
    coeff_noTorso_reduced = coeff_noTorso(:,1:idx_noTorso);
    subj.(speed_string).data.elab.coeff_noTorso_reduced = coeff_noTorso_reduced;
    
    sum_explained_ICArec = 0;
    idx_ICArec = 0;
    while sum_explained_ICArec <= explained_perc_thres
        idx_ICArec = idx_ICArec + 1;
        sum_explained_ICArec = sum_explained_ICArec + explained_ICArec(idx_ICArec);
    end
    subj.(speed_string).data.elab.numbers_of_PCs_selected_ICArec = idx_ICArec;
    coeff_ICArec_reduced = coeff_ICArec(:,1:idx_ICArec);
    subj.(speed_string).data.elab.coeff_ICArec_reduced = coeff_ICArec_reduced;
    
    subj.(speed_string).data.elab.info6 = "/******** Run PCA - Average the abs of the sensors weight along reduced component ********/";
    for i=1:size(coeff_noTorso,1) % loop on sensors
        tmp_1 = abs(coeff_noTorso_reduced(i,:));
        ave_weights_noTorso_sensors(i) = mean(tmp_1);
    end
    ave_weights_perc_noTorso_sensors = (ave_weights_noTorso_sensors./(sum(ave_weights_noTorso_sensors))).*100;
    subj.(speed_string).data.elab.ave_weights_perc_noTorso_sensors = ave_weights_perc_noTorso_sensors;
    
    for i=1:size(coeff_ICArec,1) % loop on sensors
        tmp_2 = abs(coeff_ICArec_reduced(i,:));
        ave_weights_ICArec_sensors(i) = mean(tmp_2);
    end
    ave_weights_perc_ICArec_sensors = (ave_weights_ICArec_sensors./(sum(ave_weights_ICArec_sensors))).*100;
    subj.(speed_string).data.elab.ave_weights_perc_ICArec_sensors = ave_weights_perc_ICArec_sensors;
    
    %% Dimensionality Reduction: exclude all those component with a percentage weigth less than the 10% among all components
    
    subj.(speed_string).dim_red.info7 = ['/******** Dimensionality Reduction: exclude all those component with a percentage weigth less than the ',num2str(perce_sensors_weigth_thres),'% among all components ********/'];
    
    chan_excluded_noTorso = [];
    chan_included_noTorso = [];
    h = 1;
    k = 1;
    for i=1:length(ave_weights_perc_noTorso_sensors) % loop on sensors
        if(ave_weights_perc_noTorso_sensors(i)<perce_sensors_weigth_thres)
            chan_excluded_noTorso(h) = i;
            h=h+1;
        else
            chan_included_noTorso(k) = i;
            k=k+1;
        end % end if
    end % end for i
    subj.(speed_string).dim_red.thres = perce_sensors_weigth_thres;
    subj.(speed_string).dim_red.info8 = "/******** Dimensionality Reduction - Torso Rotation Artifact Cleaned Data ********/";
    subj.(speed_string).dim_red.chans_used_noTorso = chan_included_noTorso;
    subj.(speed_string).dim_red.n_chans_used_noTorso = length(chan_included_noTorso);
    subj.(speed_string).dim_red.chans_discarded_noTorso = chan_excluded_noTorso;
    
    chan_excluded_ICArec = [];
    chan_included_ICArec = [];
    h = 1;
    k = 1;
    for i=1:length(ave_weights_perc_ICArec_sensors) % loop on sensors
        if(ave_weights_perc_ICArec_sensors(i)<perce_sensors_weigth_thres)
            chan_excluded_ICArec(h) = i;
            h=h+1;
        else
            chan_included_ICArec(k) = i;
            k=k+1;
        end % end if
    end % end for i
    subj.(speed_string).dim_red.info9 = "/******** Dimensionality Reduction - ICA Cleaned Data ********/";
    subj.(speed_string).dim_red.chans_used_ICArec = chan_included_ICArec;
    subj.(speed_string).dim_red.n_chans_used_ICArec = length(chan_included_ICArec);
    subj.(speed_string).dim_red.chans_discarded_ICArec = chan_excluded_ICArec;
        %% Alternative method to average on coeffs: Correlation between each component and all sensors (not provided in output)
    subj.(speed_string).dim_red.info6_bis = "/******** Dimensionality Reduction - correlation between all sensors in orde to find out eventual copies ********/";
    % data cleaned removing the artefact of the torso rotation
    for i=1:idx_noTorso % loop su comps che spiegano il 95% dei dati iniziali
        for j=1:size(piezo_maglia_noTorso,2) % loop su tutti i sensori
            [R_noTorso(i,j),p_noTorso(i,j)] = corr(score_noTorso(:,i), piezo_maglia_noTorso(:,j));
        end % end for j
    end % end for i
    % R and p are n_components_95% X n_sensors
    R_squared_noTorso = R_noTorso.^2;
    
    % data cleaned using ICA
    for i=1:idx_ICArec % loop su comps che spiegano il 95% dei dati iniziali
        for j=1:size(piezo_maglia_ICArec,2) % loop su tutti i sensori
            [R_ICArec(i,j),p_ICArec(i,j)] = corr(score_ICArec(:,i), piezo_maglia_ICArec(:,j));
        end % end for j
    end % end for i
    % R and p are n_components_95% X n_sensors
    R_squared_ICArec = R_ICArec.^2;
    
    % Correlazioni tra sensori
    for i=1:size(piezo_maglia_noTorso,2) % loop sui sensori
        for j=1:size(piezo_maglia_noTorso,2) % loop sui sensori
            [subj.(speed_string).dim_red.R_sens_noTorso(i,j),subj.(speed_string).dim_red.p_noTorso(i,j)] = corr(piezo_maglia_noTorso(:,i), piezo_maglia_noTorso(:,j));
        end % end for j
    end % end for i
    
        % Correlazioni tra sensori
    for i=1:size(piezo_maglia_ICArec,2) % loop sui sensori
        for j=1:size(piezo_maglia_ICArec,2) % loop sui sensori
            [subj.(speed_string).dim_red.R_sens_ICArec(i,j),subj.(speed_string).dim_red.p_ICArec(i,j)] = corr(piezo_maglia_ICArec(:,i), piezo_maglia_ICArec(:,j));
        end % end for j
    end % end for i
    %% Fatto il perf. assess. faccio e tabelle mediando le percentuali di utilizzo dei sensori sui soggetti e sulle velocità. Questo lo faccio fuori da questa funzione.
    %%
    % reference signal
    subj.(speed_string).data.spirometer_ref = spirometro_ref;
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
    
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
end % end for i subj_data

end % end function