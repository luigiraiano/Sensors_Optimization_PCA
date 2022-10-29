%% Luigi Raiano, v1, 17/03/2020
%%
clear all; close all; clc;
addpath('functions');
addpath('functions_new');
addpath('FastICA_25');
%%
disp('Choose folder containing alla data');
main_dir = uigetdir();
%% Select all folders
% Each folder is for one subject
content_list = dir(main_dir);
%% Read all available directories contaning useful information, i.e. subjects
count = 1;
for i = 1 :length(content_list)
    if(content_list(i).isdir && ~strcmp(content_list(i).name(1), '.'))
        subjs_dir_name{count} = content_list(i).name; % subjs_dir_name{count} è un char array.
        count = count + 1;
    end
end
%% Elab data for all subjects
for i=1:length(subjs_dir_name)
    subj_dir_path = [];
    subj_dir_path = [main_dir,filesep,subjs_dir_name{i}];
    
    subjs(i) = SensorsOptimizationPCA_LoadDataNoIMU_v2(subj_dir_path);
end % end for i
%% Save sbjects struct
CLK=clock;
YR=num2str(CLK(1),'%04d');
MTH=num2str(CLK(2),'%02d');
DAY=num2str(CLK(3),'%02d');
HOUR=num2str(CLK(4),'%02d');
MIN=num2str(CLK(5),'%02d');
SEC=num2str(round(CLK(6)),'%02d');
date_time = [YR,'-',MTH,'-',DAY,'_',HOUR,'.',MIN];

PathSaveFolder = ['Subjects_Data_Struct',filesep,'version_',date_time];
if(exist(PathSaveFolder)~=7) % create new folder if it does not exist
    mkdir(PathSaveFolder);
end

save([PathSaveFolder,filesep,'Subjects_Data_Struct.mat'], 'subjs', '-v7.3');