%% Luigi Raiano, v1, 03-04-2020
% This function aims at discarding redundant sensors. To check whethere a
% sensor in redundant we used the linear correlation between all sensors
% which are suppose not to bring noise. Indeed, before using this function
% we discarded the sensors which have a weight of the PCs lower than the
% 10%. Converselt, here we first check whethere there are sensors highly
% correlated with eahc other (pearson's coeff >= 0.95). Then, if the first
% check is positive, we remove among eahc pair of sensors, the one with a
% lower weight on PCs (only all those componenet needed to ecxplain the 95
% percentage of the signal). The output of this function is the input
% struct modificed, in which a new field is added: sensors_reduced.
%
% This function must be used withing the main script main_ElabNoIMU_SensorsPlacementOptimization_PCA_v3
% as sixth and 7-th step.
%
% The input parameter corr_thresh_perc must be expressed as percentag
% (0-100 %)
%
%%
function subjs_out = Discard_Redundant_Sensors_v1(subjs_in,corr_thresh_perc)
debug = 0;
subjs_out = [];
subjs_out = subjs_in;

corr_thresh = corr_thresh_perc./100;

for n=1:length(subjs_out) % loop on n subjs
    speed_list = [];
    speed_list = fieldnames(subjs_out(n).data);
    
    for j = 1:length(speed_list) % loop on speeds
        % Load vars
        U_reduced = subjs_out(n).data.(speed_list{j}).PCA.U_reduced;
        sens_to_keep_idx = subjs_out(n).data.(speed_list{j}).clean_sensors.sensors_tokeep;
        x = subjs_out(n).data.(speed_list{j}).bpflt.segnale_textile(:,sens_to_keep_idx); % n_samples X n_sensors
        w_s = subjs_out(n).data.(speed_list{j}).PCA.w_s_perc(sens_to_keep_idx);...
            % percentage weight of each sensor kept on PCs considered
        %(to explain the 95% of the input singal, i.e. the original one)
        
        %%%%% DA COMPLETARE %%%%%
        % Correletation between sensors
        R_textile = []; p = [];
        for i=1:size(x,2) % loop sui sensori
            for m=1:size(x,2) % loop sui sensori
                [R_textile(i,m),p(i,m)] = corr(x(:,i), x(:,m));
            end % end for j (sensors)
        end % end for i (sensors)
        
        % Since R is simmetric, consider only the upper side. Moreover,
        % set to zero the terms which belong to the diagonal, being the
        % correlation of each sensor with itself.
        R_up = [];
        R_up = triu(R_textile) - eye(size(R_textile));
        
        all_chans = sens_to_keep_idx; % al channs contains the clean channels only, i.e. the one that we decided to keep in point 5
        
        % The correlations of the sensors aims at understanding whethere
        % sensors that can be considered redundant. Specifically, we select
        % as redundant all those sensors that have high correletation with
        % each other, and we will kepp only the one which has a higher
        % weight in the PCs kept (which hypothetically explain the 95% of
        % the signal, which should be due above all to the breathing effect
        % instead of the noise).
        
        k = 1;
        redundant_sensors_tbremoved = [];
        comp_sensors = [];
        for i=1:size(x,2) % loop sui sensori
            for m=1:size(x,2) % loop sui sensori
                
                if(R_up(i,m) >= corr_thresh)
                    
                    % check which of the two sensors has a higher weight in PCA
                    if(w_s(i) >= w_s(m))
                        comp_sensors.(['sens_',num2str(all_chans(i)),'_vs_sens_',num2str(all_chans(m)),'_kept']) = all_chans(i);
                        redundant_sensors_tbremoved(k) = all_chans(m); % discard sensor with smaller weigth
                        k=k+1;
                    else
                        comp_sensors.(['sens_',num2str(all_chans(i)),'_vs_sens_',num2str(all_chans(m)),'_kept']) = all_chans(m);
                        redundant_sensors_tbremoved(k) = all_chans(i); % discard sensor with smaller weigth
                        k=k+1;
                        
                    end % end if-else
                end % end if
                
            end % end for m (sensors)
        end % end for i (sensors)
        
        % Select sensors to remove because too redundant
        if(~isempty(redundant_sensors_tbremoved))
            redundant_sensors_tbremoved = unique(redundant_sensors_tbremoved);
        end % end if
        
        % Select sensors to keep
        sensors_tokeep = all_chans;
        if(~isempty(redundant_sensors_tbremoved))
            red_sensors_idx = [];
            red_sensors_idx = find(ismember(sensors_tokeep,redundant_sensors_tbremoved)==1);
            sensors_tokeep(red_sensors_idx) = [];
        end % end if
        
        % Get all sensors discarded so far.
        initial_sensors = 1:size(subjs_out(n).data.(speed_list{j}).bpflt.segnale_textile,2); % all 6 sensors used in the experiment
        all_sensors_discarded = initial_sensors;
        all_sensors_discarded(sensors_tokeep) = [];
        % all_sensors_discarded is vector containing all sensors discarded (both according the first
        % discarding phase and according this second discarding phase).
        % Thus, the first method used to remove the noisy sensors and this
        % second method used to remove the ruedundant sensors.
        
        % PSD clean signals
        freq = []; P = [];
        srate = 250; % Hz
        textile_signal_nonred = subjs_out(n).data.(speed_list{j}).bpflt.segnale_textile(:,sensors_tokeep);
        for k = 1:size(textile_signal_nonred,2)
            [~, freq(:,k), P(:,k), ~] = Perform_PSD_v2(textile_signal_nonred(:,k),srate);
        end
        % Find the max peak in the ave PSD
        P_ave = mean(P,2);
        [~, idx_max] = max(P_ave);
        f_max=freq(idx_max); % frequency of the maximal peak
        f_max_bpm = f_max.*60; % breath per minute;
        
        
        % Save results
        subjs_out(n).data.(speed_list{j}).sensors_reduced.segnale_textile = subjs_out(n).data.(speed_list{j}).bpflt.segnale_textile(:,sensors_tokeep);
        subjs_out(n).data.(speed_list{j}).sensors_reduced.sensors_caparisons = comp_sensors;
        subjs_out(n).data.(speed_list{j}).sensors_reduced.redundant_sensors_tbremoved = redundant_sensors_tbremoved;
        subjs_out(n).data.(speed_list{j}).sensors_reduced.sensors_tokeep = sensors_tokeep;
        subjs_out(n).data.(speed_list{j}).sensors_reduced.all_sensors_discarded = all_sensors_discarded;
        subjs_out(n).data.(speed_list{j}).sensors_reduced.n_sensors_removed = length(redundant_sensors_tbremoved);
        subjs_out(n).data.(speed_list{j}).sensors_reduced.n_sensors_kept = length(sensors_tokeep);
        subjs_out(n).data.(speed_list{j}).sensors_reduced.n_sensors_with_redundancy = length(all_chans);
        
        subjs_out(n).data.(speed_list{j}).sensors_reduced.f_nonred = f_max;
        subjs_out(n).data.(speed_list{j}).sensors_reduced.fbpm_nonred = f_max_bpm;
        
        proof = [];
        proof = length(all_chans) - length(sensors_tokeep) - length(redundant_sensors_tbremoved); % must be zero
        
        if(round(proof) ~= 0) % at least the sensors selected an the discarded ones are correct
            warning(['proof is not zero!!! - proof = ',num2str(proof)]);
        end
        
        
    end % end for j (speeds)
    
end % end for n (subjects)
end