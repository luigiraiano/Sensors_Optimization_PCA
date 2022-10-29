%% Luigi Raiano, 13-05-2020
% This function aims at extrapolating the most used sensors on the basis of
% the results reported within the script
% main_ElabNoIMU_SensorsPlacementOptimization_PCA_v3.
% The most used sensors are the input of the function
function subjs_out = Best_Sensors_v1(subjs_in, best_sensors)

debug = 0;
subjs_out = [];
subjs_out = subjs_in;

for i=1:length(subjs_in)% (subjects' length)
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    for j=1:length(speed_list) % (speeds' length)
        textile_6_sensors = [];
        textile_best_sensors = [];
        time = [];
        f_best = [];
        fbpm_best = [];
        
        time = subjs_out(i).data.(speed_list{j}).bpflt.tempo_textile;
        textile_6_sensors = subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile;
        textile_best_sensors = textile_6_sensors(:,best_sensors);
        
        if(debug)
            figure;
            subplot(3,1,1); plot(time, textile_6_sensors); title('6 Sensors');
            subplot(3,1,2); plot(time, textile_best_sensors); title(['Best Sensors: ',num2str(best_sensors)]);
            subplot(3,1,3); plot(time, textile_6_sensors(:,[1,3,5,6]) - textile_best_sensors); title('Diff');
        end
        
        % PSD metodo massaroni 2019 ieee sens j
        freq = []; P = [];
        srate = 250; % Hz
        for h = 1:size(textile_best_sensors,2)
            [~, freq(:,h), P(:,h), ~] = Perform_PSD_v2(textile_best_sensors(:,h),srate);
        end
        
        % Find the max peak in the ave PSD
        P_ave = [];
        P_ave = mean(P,2);
        [~, idx_max] = max(P_ave);
        f_best=freq(idx_max); % frequency of the maximal peak
        fbpm_best = f_best.*60; % breath per minute;
        
        % Save variables
        subjs_out(i).data.(speed_list{j}).best_sensors.labels = best_sensors;
        subjs_out(i).data.(speed_list{j}).best_sensors.tempo_textile = time;
        subjs_out(i).data.(speed_list{j}).best_sensors.segnale_textile = textile_best_sensors;
        subjs_out(i).data.(speed_list{j}).best_sensors.f_max = f_best; % [Hz]
        subjs_out(i).data.(speed_list{j}).best_sensors.f_max_bpm = fbpm_best; % [bpm]
        
    end % end for j (speeds' length)
    
end % end for i (subjects' length)

end