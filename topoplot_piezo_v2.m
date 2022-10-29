%% Luigi Raiano, v2, 19-05-2020
% PRima di eseguire quseto script bisogna eseguire lo script
% main_ElabNoIMU_SensorsPlacementOptimization_PCA_v3

% Topoplot della percentuale di utilizzo dei sensori mediato su soggetti al
% variare della velocità

close all; clc;
%% Load silhouette
% [file, path] = uigetfile('*.png');
% fig_to_show = [path,file];
fig_to_show = ['fig_topoplot',filesep,'upper_body_male_silhouette_v2.png'];
%% Convert percentage use in numerical matrix (see result A1)

sensors_perc_use_over_speeds_num_perc = cell2mat(sensors_perc_use_over_speeds_cell);
sensors_perc_use_over_speeds_num = sensors_perc_use_over_speeds_num_perc./100;
% sensors_perc_use_over_speeds_num is a N_sensors X N_Speeds matrix
%% Define sensors position with Radii proportional to sensor uses
R = 120;
t=0:pi/50:2*pi;
sens_1 = [1250,1000]; col1 = [0,198,255]./255;
sens_2 = [1750,1000]; col2 = [30,0,129]./255;
sens_3 = [1250,1350]; col3 = [56,205,0]./255;
sens_4 = [1750,1350]; col4 = [35,129,0]./255;
sens_5 = [1250,1700]; col5 = [255,0,70]./255;
sens_6 = [1750,1700]; col6 = [179,0,49]./255;

R_sens_over_speeds = [];
for i= 1:size(sensors_perc_use_over_speeds_num,1) % loop su sensori
    for j = 1:size(sensors_perc_use_over_speeds_num,2)% loop su velocità
        R_sens_over_speeds(i,j) = R + R.*sensors_perc_use_over_speeds_num(i,j).*1.5;
    end % end for j
end % end for i

x1 = []; y1 = [];
x2 = []; y2 = [];
x3 = []; y3 = [];
x4 = []; y4 = [];
x5 = []; y5 = [];
x6 = []; y6 = [];

for i = 1:size(sensors_perc_use_over_speeds_num,2)% loop su velocità
    
    x1(:,i) = sens_1(1) + R_sens_over_speeds(1,i)*cos(t);
    y1(:,i) = sens_1(2) + R_sens_over_speeds(1,i)*sin(t);
    
    x2(:,i) = sens_2(1) + R_sens_over_speeds(2,i)*cos(t);
    y2(:,i) = sens_2(2) + R_sens_over_speeds(2,i)*sin(t);
    
    x3(:,i) = sens_3(1) + R_sens_over_speeds(3,i)*cos(t);
    y3(:,i) = sens_3(2) + R_sens_over_speeds(3,i)*sin(t);
    
    x4(:,i) = sens_4(1) + R_sens_over_speeds(4,i)*cos(t);
    y4(:,i) = sens_4(2) + R_sens_over_speeds(4,i)*sin(t);
    
    x5(:,i) = sens_5(1) + R_sens_over_speeds(5,i)*cos(t);
    y5(:,i) = sens_5(2) + R_sens_over_speeds(5,i)*sin(t);
    
    x6(:,i) = sens_6(1) + R_sens_over_speeds(6,i)*cos(t);
    y6(:,i) = sens_6(2) + R_sens_over_speeds(6,i)*sin(t);
end % end for j
%% Axes positions
fig_dimension_b = 0.333;
fig_dimension_h = 0.48;

% Axes position 3x2 subplots
pos00_ax = [];
pos00_ax = [0, 0.5, fig_dimension_b, fig_dimension_h];

pos16_ax = [];
pos16_ax = [fig_dimension_b, 0.5, fig_dimension_b, fig_dimension_h];

pos30_ax = [];
pos30_ax = [2*fig_dimension_b, 0.5, fig_dimension_b, fig_dimension_h];

pos50_ax = [];
pos50_ax = [0, 0, fig_dimension_b, fig_dimension_h];

pos66_ax = [];
pos66_ax = [fig_dimension_b, 0, fig_dimension_b, fig_dimension_h];

pos80_ax = [];
pos80_ax = [2*fig_dimension_b, 0, fig_dimension_b, fig_dimension_h];

pos_ax = [];
pos_ax = [pos00_ax; pos16_ax; pos30_ax; pos50_ax; pos66_ax; pos80_ax];

% % Axes position 2x3 subplots
% fig_dimension_h = 0.333;
% fig_dimension_b = 0.48;
% 
% pos00_ax = [];
% pos00_ax = [0, 2*fig_dimension_h, fig_dimension_b, fig_dimension_h];
% 
% pos16_ax = [];
% pos16_ax = [0.5, 2*fig_dimension_h, fig_dimension_b, fig_dimension_h];
% 
% pos30_ax = [];
% pos30_ax = [0, fig_dimension_h, fig_dimension_b, fig_dimension_h];
% 
% pos50_ax = [];
% pos50_ax = [0.5, fig_dimension_h, fig_dimension_b, fig_dimension_h];
% 
% pos66_ax = [];
% pos66_ax = [0, 0, fig_dimension_b, fig_dimension_h];
% 
% pos80_ax = [];
% pos80_ax = [0.5, 0, fig_dimension_b, fig_dimension_h];
% 
% pos_ax = [];
% pos_ax = [pos00_ax; pos16_ax; pos30_ax; pos50_ax; pos66_ax; pos80_ax];
%% All speeds
speed_list = {'Speed: 0 km h^{-1}','Speed: 1.6 km h^{-1}','Speed: 3 km h^{-1}',...
    'Speed: 5 km h^{-1}','Speed: 6.6 km h^{-1}','Speed: 8 km h^{-1}'};
fontsizetext = 22;
fontsizetext_2 = 28;
offset_senslabels = 1050;

pos_rightlabel = [sens_1(1), 600];
pos_leftlabel = [sens_2(1), 600];

figure('Position', get(0, 'Screensize'));

for i = 1:size(pos_ax,1)
    axes('Position',pos_ax(i,:));
    
    imshow(fig_to_show);
    hold on
    % Draw sensors and write theri perc. use
    patch(x1(:,i), y1(:,i), col1);
    text(sens_1(1), sens_1(2), [num2str(sensors_perc_use_over_speeds_num_perc(1,i)),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    text(sens_1(1)-offset_senslabels, sens_1(2), ['S. 1'],'Color',col1,'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    patch(x2(:,i), y2(:,i), col2);
    text(sens_2(1), sens_2(2), [num2str(sensors_perc_use_over_speeds_num_perc(2,i)),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    text(sens_2(1)+offset_senslabels, sens_2(2), ['S. 2'],'Color',col2,'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    patch(x3(:,i), y3(:,i), col3);
    text(sens_3(1), sens_3(2), [num2str(sensors_perc_use_over_speeds_num_perc(3,i)),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    text(sens_3(1)-offset_senslabels, sens_3(2), ['S. 3'],'Color',col3,'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    patch(x4(:,i), y4(:,i), col4);
    text(sens_4(1), sens_4(2), [num2str(sensors_perc_use_over_speeds_num_perc(4,i)),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    text(sens_4(1)+offset_senslabels, sens_4(2), ['S. 4'],'Color',col4,'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    patch(x5(:,i), y5(:,i), col5);
    text(sens_5(1), sens_5(2), [num2str(sensors_perc_use_over_speeds_num_perc(5,i)),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    text(sens_5(1)-offset_senslabels, sens_5(2), ['S. 5'],'Color',col5,'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    patch(x6(:,i), y6(:,i), col6);
    text(sens_6(1), sens_6(2), [num2str(sensors_perc_use_over_speeds_num_perc(6,i)),'%'],'Color','w','FontSize',fontsizetext,'Units','data','HorizontalAlignment','center');
    text(sens_6(1)+offset_senslabels, sens_6(2), ['S. 6'],'Color',col6,'FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    
    text(pos_rightlabel(1), pos_rightlabel(2), ['Right'],'Color','k','FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    text(pos_leftlabel(1), pos_leftlabel(2), ['Left'],'Color','k','FontSize',fontsizetext_2,'Units','data','HorizontalAlignment','center');
    
    title(gca, speed_list{i},'FontSize',32);
end