function subj = Elab_data_Textile_Breathing_v1(subj_dir_path,subjs_dir_name)
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
    
    srate = 250; % Hz
    
    subj.(speed_string).speed = speed/10; % [km/h]
    subj.(speed_string).srate = srate;
    subj.(speed_string).data.textile_raw = piezo_maglia;
    
    % reference signal
    subj.(speed_string).data.spirometer_ref = spirometro_ref;
    
    %% Discard too noisy channels
    % A channel is discarded if the PSD has at least one armonic above 1 Hz that
    % wieghts more then the 30% of the PSD amplitude.
    % figure;
    discard_channels = [];
    for i=1:size(piezo_maglia,2)
        [f_sigs_raw(i),discard_channels(i)] = PSD_v3(piezo_maglia(:,i)',srate,'discard_channels','donotplot');
    end % end for i
    %% Remove Signal too noisy
    chans_ok = [];
    chans_ok = find(discard_channels==0);
    piezo_maglia_new = piezo_maglia(:,chans_ok);
    
    subj.(speed_string).channel_used = chans_ok;
    subj.(speed_string).n_channel_used = length(chans_ok);
    subj.(speed_string).data.taxtile_chok = piezo_maglia_new;
    %% Run ICA by means RobustICA algorithm (zarzoso et al 2010)
    % ronbustica wants n_signals X n_samples matrices
    % ICA is run without reducing the dimensionality
    
    [IC, H, iter, magnification] = Run_ICA_v2(piezo_maglia_new');
    %% Select components
    % A component is discarded if the PSD has at least one armonic above 0.9 Hz that
    % wieghts more then the 40% of the PSD amplitude.
    discard_ics = [];
    for i=1:size(IC,1)
        [freq_Hz_ic(i,:),discard_ics(i)] = PSD_v3(IC(i,:),srate,'discard_ica','donotplot');
    end % end for i
    
    % Select components and reconstruct the signal
    selectedICs = [];
    selectedICs=find(discard_ics==0);
    piezo_maglia_new_rec = Clean_With_ICs_v3(IC,H,selectedICs,magnification);
    
    subj.(speed_string).ica.comps_used = selectedICs;
    subj.(speed_string).ica.n_comps_used = length(selectedICs);
    subj.(speed_string).ica.components = IC;
    subj.(speed_string).ica.weigthMatrix = H;
    subj.(speed_string).ica.magnification = magnification;
    
    subj.(speed_string).data.taxtile_rec = piezo_maglia_new_rec;
    %% Media nel tempo di tutti i segnali
    segnali_ave_ok = 1:length(chans_ok);
    % piezo_maglia_new_rec_ave = mean(piezo_maglia_new_rec(:,segnali_ave_ok),2);
    piezo_maglia_new_rec_ave = mean(piezo_maglia_new_rec,2);
    subj.(speed_string).data.textile_rec_ave = piezo_maglia_new_rec_ave;
    
    %% Get breathing frequencies
    subj.(speed_string).data.f_breathing_textile_ave = Get_Mean_Breathing_Rate_v1(piezo_maglia_new_rec_ave,srate,0.5);
    subj.(speed_string).data.f_breathing_spirometer_ave = Get_Mean_Breathing_Rate_v1(spirometro_ref,srate,0.3);
    
    is_breath_rate_right = isequal(subj.(speed_string).data.f_breathing_textile_ave,subj.(speed_string).data.f_breathing_spirometer_ave);
    
    if(is_breath_rate_right)
        subj.(speed_string).breathing_rate_properly_measured = true;
    else
        subj.(speed_string).breathing_rate_properly_measured = false;
    end
    
    disp(['Subj: ',subj_id,' - Speed: ',speed_string,' Processed']);
end % end for i subj_data
end % end function