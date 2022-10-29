%% Luigi Raiano, v1, 19-05-2020
% PRima di eseguire quseto script bisogna eseguire lo script
% main_ElabNoIMU_SensorsPlacementOptimization_PCA_v3

% Topoplot della percentuale di utilizzo dei sensori mediato su soggetti e
% velocità (singola figura)

close all; clc;
%% Load silhouette
% [file, path] = uigetfile('*.png');
% fig_to_show = [path,file];
fig_to_show = ['fig_topoplot',filesep,'upper_body_male_silhouette_v2.png'];
%% Convert percentage use in numerical matrix (see result A1)
sensors_perc_use_overall_num_perc = cell2mat(sensors_perc_use_overall_cell);
sensors_perc_use_overall_num = sensors_perc_use_overall_num_perc./100;
% sensors_perc_use_over_speeds_num is a N_sensors X N_Speeds matrix
%% Define sensors position with Radii proportional to sensor uses
R = 90;
t=0:pi/50:2*pi;
sens_1 = [1250,1000]; col1 = [0,198,255]./255;
sens_2 = [1750,1000]; col2 = [30,0,129]./255;
sens_3 = [1250,1350]; col3 = [56,205,0]./255;
sens_4 = [1750,1350]; col4 = [35,129,0]./255;
sens_5 = [1250,1700]; col5 = [255,0,70]./255;
sens_6 = [1750,1700]; col6 = [179,0,49]./255;

sens_pos = [sens_1; sens_2; sens_3; sens_4; sens_5; sens_6];
cols = [col1; col2; col3; col4; col5; col6];

R_sens = [];
for i= 1:size(sensors_perc_use_overall_num,1) % loop su sensori
    R_sens(i) = R + R.*sensors_perc_use_overall_num(i).*2;
end % end for i

x = [];
y = [];

for i=1:length(R_sens) % loop on sensors
    x(i,:) = sens_pos(i,1) + R_sens(i)*cos(t);
    y(i,:) = sens_pos(i,2) + R_sens(i)*sin(t);
end 
    
% x1 = sens_1(1) + R_sens_over_speeds(1)*sin(t);
% y1 = sens_1(2) + R_sens_over_speeds(1)*cos(t);
% 
% x2 = sens_2(1) + R_sens_over_speeds(2)*sin(t);
% y2 = sens_2(2) + R_sens_over_speeds(2)*cos(t);
% 
% x3 = sens_3(1) + R_sens_over_speeds(3)*sin(t);
% y3 = sens_3(2) + R_sens_over_speeds(3)*cos(t);
% 
% x4 = sens_4(1) + R_sens_over_speeds(4)*sin(t);
% y4 = sens_4(2) + R_sens_over_speeds(4)*cos(t);
% 
% x5 = sens_5(1) + R_sens_over_speeds(5)*sin(t);
% y5 = sens_5(2) + R_sens_over_speeds(5)*cos(t);
% 
% x6 = sens_6(1) + R_sens_over_speeds(6)*sin(t);
% y6 = sens_6(2) + R_sens_over_speeds(6)*cos(t);

%% Make topoplot
fontsizetext = 35;
fontsizetext_2 = 50;
offset_senslabels = 1000;

pos_rightlabel = [sens_pos(1,1), 600];
pos_leftlabel = [sens_pos(2,1), 600];

figure('Position', get(0, 'Screensize'));

imshow(fig_to_show);
hold on
% Draw sensors
for i= 1:length(R_sens)% loop su sensori
    patch(x(i,:), y(i,:), cols(i,:));
    text(sens_pos(i,1), sens_pos(i,2), [num2str(round(sensors_perc_use_overall_num_perc(i))),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    if(mod(i,2) == 0) % pari
        text(sens_pos(i,1)+offset_senslabels, sens_pos(i,2), ['S. ',num2str(i)],'Color',cols(i,:),'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    else % dispari
        text(sens_pos(i,1)-offset_senslabels, sens_pos(i,2), ['S. ',num2str(i)],'Color',cols(i,:),'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    end
    
    text(pos_rightlabel(1), pos_rightlabel(2), ['Right'],'Color','k','FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    text(pos_leftlabel(1), pos_leftlabel(2), ['Left'],'Color','k','FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
end
% title('Average Percentage Use','FontSize',fontsizetext_2);