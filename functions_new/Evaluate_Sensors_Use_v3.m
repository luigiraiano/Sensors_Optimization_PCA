%% Luigi Raiano, v3, 03-04-2020
% This function must be used within the script main script
% main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v1, after having
% discarded sensors using the PCA based method.
%
% Output
% 1-    Use of sensors with respect each subject (averaged on speeds). The
%       result expresses the use of each sensor with respect all subjects
%       enrolled, grouping all speeds recorded (here I loose the information of the
%       single speed). -> N_sensors X N_subjects cell matrix
% 2-    cell matrix containing the Use of sensors with respect each speed (averaged on subjects). The
%       results expresses the percentage of use of each sensor with respect all
%       speeds, grouping all subjects recorded (here I loose the information of
%       the singole subject). -> N_sensors X N_speeds cell matrix
% 3-    Percentage of use grouping all subjects and all speed. The result
%       expressed the general use of each sensor in all data recorded. ->
%       N_sensors X 1 cell array
%
%%
function [sensors_perc_use_over_subjects_cell, sensors_perc_use_over_speeds_cell, sensors_perc_use_overall_cell] = Evaluate_Sensors_Use_v3(subjs_in)
% check the preasence of the sensor within each subject for each speed.
% si o no. Perc = si/si+no

% Sensors use matrices. Dimesnions: N_Subjs X N_Sensors. Value: 1 ->
% sensor used, 0 -> sensor unused.
sensor1_use = [];
sensor2_use = [];
sensor3_use = [];
sensor4_use = [];
sensor5_use = [];
sensor6_use = [];

n_subjs = length(subjs_in);
for i=1:n_subjs
    speed_list = [];
    speed_list = fieldnames(subjs_in(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds
        % sensors used for the subject i-th at the speed j-th (array)
%         subji_speedj_sensors_used = subjs_in(i).data.(speed_list{j}).sensors_reduced.sensors_tokeep;
        all_sensors = [];
        all_sensors = 1:6;
        clean_sensors = [];
        clean_sensors = subjs_in(i).data.(speed_list{j}).clean_sensors.sensors_kept_label;
        non_redundant_sensors = [];
        non_redundant_sensors = subjs_in(i).data.(speed_list{j}).sensors_reduced.sensors_tokeep;
        all_sensors_discarded = subjs_in(i).data.(speed_list{j}).sensors_reduced.all_sensors_discarded;
        
        for k=1:length(non_redundant_sensors) % loop on sensors
            command_to_launch = [];
            command_to_launch = ['sensor',num2str(non_redundant_sensors(k)),...
                '_use(i,j) = sum(ismember(non_redundant_sensors(k),all_sensors));'];
            eval(command_to_launch);
        end % end for k (all sensors)
        
        k = 1;
        for k=1:length(all_sensors_discarded) % loop on sensors
            command_to_launch = [];
            command_to_launch = ['sensor',num2str(all_sensors_discarded(k)),...
                '_use(i,j) = 0;'];
            eval(command_to_launch);
        end % end for k (all sensors)
        
        debug = 1;
    end % end for j
end % end for i

% Average use % Definitions
% sensor(i)_perc_use_over_subjects := (sum(sensor(i)_use(j,:))/n_speeds)*100;
% for each i the result is a n_subjs % X 1 vector

% sensor(i)_perc_use_over_speeds := (sum(sensor(i)_use(:,j))/n_subjects)*100;
% for each i the result is a n_speeds % X 1 vector

% Use of sensors with respect each subject (averaged on speeds). The
% result expresses the use of each sensor with respect all subjects
% enrolled, grouping all speeds recorded (here I loose the information of the
% single speed).
sensor1_perc_use_over_subjects = [];
sensor2_perc_use_over_subjects = [];
sensor3_perc_use_over_subjects = [];
sensor4_perc_use_over_subjects = [];
sensor5_perc_use_over_subjects = [];
sensor6_perc_use_over_subjects = [];
for j = 1:n_subjs
    sensor1_perc_use_over_subjects(j) = (sum(sensor1_use(j,:))/n_speeds).*100;
    sensor2_perc_use_over_subjects(j) = (sum(sensor2_use(j,:))/n_speeds).*100;
    sensor3_perc_use_over_subjects(j) = (sum(sensor3_use(j,:))/n_speeds).*100;
    sensor4_perc_use_over_subjects(j) = (sum(sensor4_use(j,:))/n_speeds).*100;
    sensor5_perc_use_over_subjects(j) = (sum(sensor5_use(j,:))/n_speeds).*100;
    sensor6_perc_use_over_subjects(j) = (sum(sensor6_use(j,:))/n_speeds).*100;
end % end for j
% Put together all data
sensors_perc_use_over_subjects = []; % N_sensors X N_subjetcs
sensors_perc_use_over_subjects = [sensor1_perc_use_over_subjects; sensor2_perc_use_over_subjects;...
    sensor3_perc_use_over_subjects; sensor4_perc_use_over_subjects;...
    sensor5_perc_use_over_subjects; sensor6_perc_use_over_subjects];
sensors_perc_use_over_subjects = round(sensors_perc_use_over_subjects,2);

sensors_perc_use_over_subjects_cell = num2cell(sensors_perc_use_over_subjects); % converts into cell matrix

% Use of sensors with respect each speed (averaged on subjects). The
% results expresses the percentage of use of each sensor with respect all
% speeds, grouping all subjects recorded (here I loose the information of
% the singole subject).
sensor1_perc_use_over_speeds = [];
sensor2_perc_use_over_speeds = [];
sensor3_perc_use_over_speeds = [];
sensor4_perc_use_over_speeds = [];
sensor5_perc_use_over_speeds = [];
sensor6_perc_use_over_speeds = [];
for j=1:n_speeds
    sensor1_perc_use_over_speeds(j) = (sum(sensor1_use(:,j))./n_subjs)*100;
    sensor2_perc_use_over_speeds(j) = (sum(sensor2_use(:,j))./n_subjs)*100;
    sensor3_perc_use_over_speeds(j) = (sum(sensor3_use(:,j))./n_subjs)*100;
    sensor4_perc_use_over_speeds(j) = (sum(sensor4_use(:,j))./n_subjs)*100;
    sensor5_perc_use_over_speeds(j) = (sum(sensor5_use(:,j))./n_subjs)*100;
    sensor6_perc_use_over_speeds(j) = (sum(sensor6_use(:,j))./n_subjs)*100;
end % end for j
% Put together all data
sensors_perc_use_over_speeds = []; % N_Sensors X N_speeds
sensors_perc_use_over_speeds = [sensor1_perc_use_over_speeds; sensor2_perc_use_over_speeds;...
    sensor3_perc_use_over_speeds; sensor4_perc_use_over_speeds;...
    sensor5_perc_use_over_speeds; sensor6_perc_use_over_speeds];
sensors_perc_use_over_speeds = round(sensors_perc_use_over_speeds,2);

sensors_perc_use_over_speeds_cell = num2cell(sensors_perc_use_over_speeds); % converts into cell matrix

% Percentage of use grouping all subjects and all speed. The result
% expressed the general use of each sensor in all data recorded.
sensors_perc_use_overall_a = []; % N_sensors X 1
sensors_perc_use_overall_a = mean(sensors_perc_use_over_subjects,2);
sensors_perc_use_overall_b = []; % N_sensors X 1
sensors_perc_use_overall_b = mean(sensors_perc_use_over_speeds,2);

% CHECK: sensors_perc_use_overall_a must be the same as
% sensors_perc_use_overall_b. -> check = zeros(n_sensors,1).
check = round(sensors_perc_use_overall_a - sensors_perc_use_overall_b,2);

sensors_perc_use_overall_cell = num2cell(sensors_perc_use_overall_b);
end % end function