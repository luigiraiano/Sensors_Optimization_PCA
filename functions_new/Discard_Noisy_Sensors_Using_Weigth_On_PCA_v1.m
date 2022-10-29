%% Luigi Raiano, v1, 02-04-2020
% This function aims at discarding sensors on the basis of their wieght on
% PCs kept using Compute_Sensor_Weight_Over_PCs_Kept_v1 function.
% Specifically, on the basis of the threshold defined by
% discard_perc_thres, this function removes all those component that have
% low weight (w_s < discard_perc_thres). Such a procedure is based on the
% rationale that the 95% of the principal componets is enough to describe
% the hole singal and even to remove some noise.
%%
function subjs_out = Discard_Noisy_Sensors_Using_Weigth_On_PCA_v1(subjs_in, discard_perc_thres)

debug = 0;
subjs_out = [];
subjs_out = subjs_in;

w_s = [];
for n=1:length(subjs_out) % loop on n subjs
    
    speed_list = [];
    speed_list = fieldnames(subjs_out(n).data);
    
    for j = 1:length(speed_list) % loop on speeds
        % Load variables
        % Percentage weights of each sensors on all components kept
        w_s(:,j,n) = subjs_out(n).data.(speed_list{j}).PCA.w_s_perc; % n_sensors x 1 vecotor
        
        k=1;
        sensors_tbd = []; % array containing the index of the sensors to be discarded
        for i=1:size(w_s,1) % loop on sensors
            if(w_s(i,j,n) <= discard_perc_thres)
                sensors_tbd(k) = i;
                k = k+1;
            end % end if
        end % end for i
        
        sensors_tb_discarded(n,j).sensors = sensors_tbd;
        all_sensors = 1:size(w_s,1);
        find_sensors_to_remove = ismember(all_sensors,sensors_tbd);
        sensors_to_keep_idx = find(find_sensors_to_remove==0);
        sensor_to_keep = all_sensors(sensors_to_keep_idx);
        n_sensors_discarded(n,j) = length(sensors_tbd);
        n_sensors_kept(n,j) = length(sensor_to_keep);
        
        % PSD clean signals
        freq = []; P = [];
        srate = 250; % Hz
        textile_signal = subjs_out(n).data.(speed_list{j}).bpflt.segnale_textile;
        textile_signal_clean = textile_signal(:,sensor_to_keep);
        for k = 1:size(textile_signal_clean,2)
            [~, freq(:,k), P(:,k), ~] = Perform_PSD_v2(textile_signal_clean(:,k),srate);
        end
        % Find the max peak in the ave PSD
        P_ave = mean(P,2);
        [~, idx_max] = max(P_ave);
        f_max=freq(idx_max); % frequency of the maximal peak
        f_max_bpm = f_max.*60; % breath per minute;
        
        % Save results
        subjs_out(n).data.(speed_list{j}).clean_sensors.sensors_tokeep = sensor_to_keep;
        subjs_out(n).data.(speed_list{j}).clean_sensors.all_sensors_discarded = sensors_tbd;
        
        subjs_out(n).data.(speed_list{j}).clean_sensors.segnale_textile = textile_signal(:,sensor_to_keep);
        subjs_out(n).data.(speed_list{j}).bpflt.segnale_textile_clean = textile_signal(:,sensor_to_keep);
        subjs_out(n).data.(speed_list{j}).clean_sensors.n_sensors_kept = n_sensors_kept(n,j);
        subjs_out(n).data.(speed_list{j}).clean_sensors.n_sensors_discarded = n_sensors_discarded(n,j);
        
        subjs_out(n).data.(speed_list{j}).clean_sensors.f_clean = f_max;
        subjs_out(n).data.(speed_list{j}).clean_sensors.fbpm_clean = f_max_bpm;
        
    end % end for j
    
end % end for n

end % end function