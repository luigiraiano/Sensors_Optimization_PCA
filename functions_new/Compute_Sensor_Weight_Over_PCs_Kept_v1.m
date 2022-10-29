%% Luigi Raiano, v1. 02-04-2020
% This funnction aims at evaluating the wieght of the textile sensors on
% PCs kept and must be run within the main script
% main_ElabNoIMU_SensorPlacementOoptimizazione_PCA_v3.m
%%
function subjs_out = Compute_Sensor_Weight_Over_PCs_Kept_v1(subjs_in)

debug = 0;
subjs_out = subjs_in;

for n=1:length(subjs_out) % loop on # subjs
    speed_list = [];
    speed_list = fieldnames(subjs_out(n).data);
    
    for j = 1:length(speed_list)
        % Load variables
        U_reduced = subjs_out(n).data.(speed_list{j}).PCA.U_reduced;
        
        % compute the weith of the sensor i at speed j for the subject n
        % w_s is a n_sensors X n_speeds X n_subjects matrix
        for i=1:size(U_reduced,1) % loop on sensors
            w_s(i,j,n) = sum(abs(U_reduced(i,:)));
        end % end for i
        % Compute the sum of the weight of the all sensors on the
        % componenets kept
        sum_w_sensors(j,n) = sum(w_s(:,j,n));
        
        % Get percentage of w_s according to fomula presented in report Report_Breathing_PCA_2020-03-31_v1.pptx
        for i=1:size(U_reduced,1) % loop on sensors
            w_s_perc(i,j,n) = (w_s(i,j,n)./(sum_w_sensors(j,n))).*100;
        end % end for i
        
        % Store weights in main struct (both absolute and relative
        % expressed as percentage).
        subjs_out(n).data.(speed_list{j}).PCA.w_s = w_s(:,j,n);
        subjs_out(n).data.(speed_list{j}).PCA.w_s_perc = w_s_perc(:,j,n);
        
        % Proof: sum of subjs_out(n).data.(speed_list{j}).PCA.w_s_perc must
        % be equal to 100 for each speed and each subject!
        proof = 0;
        proof = sum(subjs_out(n).data.(speed_list{j}).PCA.w_s_perc);
        if(round(proof) ~= 100)
            warning(['the sum of the weigh of the sensors for subj ',num2str(n),' at speed ',speed_list{j},' is not 100%']);
        end % end if
            
        
    end % end for j
    
end % end for n

end % end function