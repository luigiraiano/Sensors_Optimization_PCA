%% Luigi Raiano, v1, 19-03-2020
% Run PCA on all signals (textile). This function must be used within the
% main script main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v1.
%
% corr_thresh: is expressed in [%], thus it ranges from 0-100
%
%%
function subjs_out = Sensors_Selection_PCA_Based_v1(subjs_in, corr_thresh)
debug = 0;
subjs_out = subjs_in;
corr_thresh = corr_thresh/100; % range: 0-1;

n_subjs = length(subjs_in);
for i=1:n_subjs
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds
        % Load variables
        x = subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile; % n_samples X n_sensors
        U = subjs_out(i).data.(speed_list{j}).PCA.U;
        explained = subjs_out(i).data.(speed_list{j}).PCA.variance_explained;
        idx_explained = subjs_out(i).data.(speed_list{j}).PCA.idx_explained;
        U_reduced = subjs_out(i).data.(speed_list{j}).PCA.U_reduced;
        
        % Correletation between sensors
        R_textile = []; p = [];
        for n=1:size(x,2) % loop sui sensori
            for m=1:size(x,2) % loop sui sensori
                [R_textile(n,m),p(n,m)] = corr(x(:,n), x(:,m));
            end % end for j
        end % end for i
        % Despite R is simmetric, consider only the upper side. Moreover,
        % set to zero the terms which belong to the diagonal, being the
        % correlation of each sensor with itself.
        R_up = triu(R_textile) - eye(size(R_textile));
        
        all_chans = 1:6;
        
        % Sulla base della correlazione, tieni fra i due in esame quello che ha
        % peso maggiore sulle componenti che spiegano la percentuale di segnale
        % di soglia. Il calcol o del contributo che un sensore ha sulle componenti è
        % il seguente:
        % sum(abs(U_reduced(i,:))) -> contributo del sensore i-imo sulle componenti
        %                             scelte
        
        k = 1;
        sensors_tbremoved = [];
        comp_sensors = [];
        for n=1:size(x,2) % loop sui sensori
            for m=1:size(x,2) % loop sui sensori
                if(R_up(n,m) >= corr_thresh)
                    % check which of the two sensors has a higher weight in PCA
                    if(sum(abs(U_reduced(n,:))) >= sum(abs(U_reduced(m,:))))
                        comp_sensors.(['sens_',num2str(n),'_vs_sens_',num2str(m),'_kept']) = n;
                        sensors_tbremoved(k) = m; % discard sensor with smaller weigth
                        k=k+1;
                    else
                        comp_sensors.(['sens_',num2str(n),'_vs_sens_',num2str(m),'_kept']) = m;
                        sensors_tbremoved(k) = n; % discard sensor with smaller weigth
                        k=k+1;
                    end % end if-else
                end % end if
            end % end for m
        end % end for n
        
        % Select sensors to remove because too redundant
        if(~isempty(sensors_tbremoved))
            sensors_tbremoved = unique(sensors_tbremoved);
        end % end if
        
        % Select sensors to keep
        sensors_tokeep = all_chans;
        if(~isempty(sensors_tbremoved))
            sensors_tokeep(sensors_tbremoved) = [];
        end % end if
        
        % Save results
        subjs_out(i).data.(speed_list{j}).sensor_reduced.sensors_caparisons = comp_sensors;
        subjs_out(i).data.(speed_list{j}).sensor_reduced.sensors_tbremoved = sensors_tbremoved;
        subjs_out(i).data.(speed_list{j}).sensor_reduced.sensors_tokeep = sensors_tokeep;
        subjs_out(i).data.(speed_list{j}).sensor_reduced.n_sensors_removed = length(sensors_tbremoved);
        subjs_out(i).data.(speed_list{j}).sensor_reduced.n_sensors_kept = length(sensors_tokeep);
        
    end % end for j
    
end % end for i

end % end function