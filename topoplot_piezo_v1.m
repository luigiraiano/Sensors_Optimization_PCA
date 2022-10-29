%% Load silhouette
% [file, path] = uigetfile('*.png');
% fig_to_show = [path,file];
fig_to_show = ['fig_topoplot',filesep,'upper_body_male_silhouette_v2.png'];
%% Convert percentage use in numerical matrix (see result A1)

sensors_perc_use_over_speeds_num_perc = cell2mat(sensors_perc_use_over_speeds_cell);
sensors_perc_use_over_speeds_num = sensors_perc_use_over_speeds_num_perc./100;
% sensors_perc_use_over_speeds_num is a N_sensors X N_Speeds matrix
%% Define sensors postion with constant Radii
R = 100;
t=0:pi/50:2*pi;
sens_1 = [1250,1000]; R1 = R; col1 = [0,198,255]./255;
sens_2 = [1750,1000]; R2 = R; col2 = [30,0,129]./255;
sens_3 = [1250,1350]; R3 = R; col3 = [56,205,0]./255;
sens_4 = [1750,1350]; R4 = R; col4 = [35,129,0]./255;
sens_5 = [1250,1700]; R5 = R; col5 = [255,0,70]./255;
sens_6 = [1750,1700]; R6 = R; col6 = [179,0,49]./255;
%x_o and y_o = center of circle
x1 = sens_1(1) + R1*sin(t);
y1= sens_1(2) + R1*cos(t);

x2 = sens_2(1) + R1*sin(t);
y2= sens_2(2) + R1*cos(t);

x3 = sens_3(1) + R1*sin(t);
y3= sens_3(2) + R1*cos(t);

x4 = sens_4(1) + R1*sin(t);
y4= sens_4(2) + R1*cos(t);

x5 = sens_5(1) + R1*sin(t);
y5= sens_5(2) + R1*cos(t);

x6 = sens_6(1) + R1*sin(t);
y6= sens_6(2) + R1*cos(t);
%% Define sensors position with Radii proportional to sensor uses
R = 100;
t=0:pi/50:2*pi;
sens_1 = [1250,1000]; col1 = [0,198,255]./255;
sens_2 = [1750,1000]; col2 = [30,0,129]./255;
sens_3 = [1250,1350]; col3 = [56,205,0]./255;
sens_4 = [1750,1350]; col4 = [35,129,0]./255;
sens_5 = [1250,1700]; col5 = [255,0,70]./255;
sens_6 = [1750,1700]; col6 = [179,0,49]./255;

R_ses_over_speeds = [];
for i= 1:size(sensors_perc_use_over_speeds_num,1) % loop su sensori
    for j = 1:size(sensors_perc_use_over_speeds_num,2)% loop su velocità
        R_ses_over_speeds(i,j) = R + R.*sensors_perc_use_over_speeds_num(i,j).*2;
    end % end for j
end % end for i

x1 = []; y1 = [];
x2 = []; y2 = [];
x3 = []; y3 = [];
x4 = []; y4 = [];
x5 = []; y5 = [];
x6 = []; y6 = [];

for j = 1:size(sensors_perc_use_over_speeds_num,2)% loop su velocità
    
    x1(:,j) = sens_1(1) + R_ses_over_speeds(1,j)*sin(t);
    y1(:,j)= sens_1(2) + R_ses_over_speeds(1,j)*cos(t);
    
    x2(:,j) = sens_2(1) + R_ses_over_speeds(2,j)*sin(t);
    y2(:,j) = sens_2(2) + R_ses_over_speeds(2,j)*cos(t);
    
    x3(:,j) = sens_3(1) + R_ses_over_speeds(3,j)*sin(t);
    y3(:,j) = sens_3(2) + R_ses_over_speeds(3,j)*cos(t);
    
    x4(:,j) = sens_4(1) + R_ses_over_speeds(4,j)*sin(t);
    y4(:,j) = sens_4(2) + R_ses_over_speeds(4,j)*cos(t);
    
    x5(:,j) = sens_5(1) + R_ses_over_speeds(5,j)*sin(t);
    y5(:,j) = sens_5(2) + R_ses_over_speeds(5,j)*cos(t);
    
    x6(:,j) = sens_6(1) + R_ses_over_speeds(6,j)*sin(t);
    y6(:,j) = sens_6(2) + R_ses_over_speeds(6,j)*cos(t);
end % end for j
%% Axes positions
fig_dimension = 0.35;

% Axes position
pos00_ax = [];
pos00_ax = [0, 0.55, fig_dimension, fig_dimension];

pos16_ax = [];
pos16_ax = [fig_dimension, 0.55, fig_dimension, fig_dimension];

pos30_ax = [];
pos30_ax = [2*fig_dimension, 0.55, fig_dimension, fig_dimension];

pos50_ax = [];
pos50_ax = [0, 0.1, fig_dimension, fig_dimension];

pos66_ax = [];
pos66_ax = [fig_dimension, 0.1, fig_dimension, fig_dimension];

pos80_ax = [];
pos80_ax = [2*fig_dimension, 0.1, fig_dimension, fig_dimension];

pos_ax = [];
pos_ax = [pos00_ax; pos16_ax; pos30_ax; pos50_ax; pos66_ax; pos80_ax];
%% All speeds
figure('Position', get(0, 'Screensize'));

for i = 1:size(pos_ax,1)
    axes('Position',pos_ax(i,:));
    
    imshow(fig_to_show);
    hold on
    % Draw sensors
    patch(x1(:,i), y1(:,i), col1);
    patch(x2(:,i), y2(:,i), col2);
    patch(x3(:,i), y3(:,i), col3);
    patch(x4(:,i), y4(:,i), col4);
    patch(x5(:,i), y5(:,i), col5);
    patch(x6(:,i), y6(:,i), col6);
    
    title(gca, 'Speed: 0 km h^{-1}','FontSize',30);
end
%% Speed 0 km/h
% speed00_ax = subplot(2,3,1);
% pos00_ax = [];
% pos00_ax = [speed00_ax.Position(1), speed00_ax.Position(2), fig_dimension, fig_dimension];
% set(speed00_ax,'Position',pos00_ax);

% subplot('Position',pos00_ax);
axes('Position',pos00_ax);

imshow(fig_to_show);
hold on

% plot(x,y,'r');
% fill(sens_1(1),sens_1(2),col1);
patch(x1,y1,col1);
patch(x2,y2,col2);
patch(x3,y3,col3);
patch(x4,y4,col4);
patch(x5,y5,col5);
patch(x6,y6,col6);
title('Speed: 0 km h^{-1}','FontSize',30);
%% Speed 1.6 km/h
% speed16_ax = subplot(2,3,2);
% pos16_ax = [];
% pos16_ax = [speed16_ax.Position(1), speed16_ax.Position(2), fig_dimension, fig_dimension];
% set(gca,'Position',pos16_ax);

subplot('Position',pos16_ax);
% axes('Position',pos16_ax);

imshow(fig_to_show);
hold on

% plot(x,y,'r');
% fill(sens_1(1),sens_1(2),col1);
patch(x1,y1,col1); hold on;
patch(x2,y2,col2); hold on;
patch(x3,y3,col3); hold on;
patch(x4,y4,col4); hold on;
patch(x5,y5,col5); hold on;
patch(x6,y6,col6); hold on;
title('Speed: 1.6 km h^{-1}','FontSize',30);
%% Speed 3 km/h
% speed30_ax = subplot(2,3,3);
% pos30_ax = [];
% pos30_ax = [speed30_ax.Position(1), speed30_ax.Position(2), fig_dimension, fig_dimension];
% set(speed30_ax,'Position',pos30_ax);

% subplot('Position',pos30_ax);
axes('Position',pos30_ax);

imshow(fig_to_show);
hold on

% plot(x,y,'r');
% fill(sens_1(1),sens_1(2),col1);
patch(x1,y1,col1); hold on;
patch(x2,y2,col2); hold on;
patch(x3,y3,col3); hold on;
patch(x4,y4,col4); hold on;
patch(x5,y5,col5); hold on;
patch(x6,y6,col6); hold on;
title('Speed: 3 km h^{-1}','FontSize',30);
%% Speed 5 km/h
% speed50_ax = subplot(2,3,4);
% pos50_ax = [];
% pos50_ax = [speed50_ax.Position(1), speed50_ax.Position(2), fig_dimension, fig_dimension];
% set(speed50_ax,'Position',pos50_ax);

% subplot('Position',pos50_ax);
axes('Position',pos50_ax);

imshow(fig_to_show);
hold on

% plot(x,y,'r');
% fill(sens_1(1),sens_1(2),col1);
patch(x1,y1,col1); hold on;
patch(x2,y2,col2); hold on;
patch(x3,y3,col3); hold on;
patch(x4,y4,col4); hold on;
patch(x5,y5,col5); hold on;
patch(x6,y6,col6); hold on;
title('Speed: 5 km h^{-1}','FontSize',30);
%% Speed 6.6 km/h
% speed66_ax = subplot(2,3,5);
% pos66_ax = [];
% pos66_ax = [speed66_ax.Position(1), speed66_ax.Position(2), fig_dimension, fig_dimension];
% set(speed66_ax,'Position',pos66_ax);

% subplot('Position',pos66_ax);
axes('Position',pos66_ax);

imshow(fig_to_show);
hold on
x1 = sens_1(1) + R1*sin(t);
y1= sens_1(2) + R1*cos(t);
% plot(x,y,'r');
% fill(sens_1(1),sens_1(2),col1);
patch(x1,y1,col1); hold on;
patch(x2,y2,col2); hold on;
patch(x3,y3,col3); hold on;
patch(x4,y4,col4); hold on;
patch(x5,y5,col5); hold on;
patch(x6,y6,col6); hold on;
title('Speed: 6.6 km h^{-1}','FontSize',30);
%% Speed 8 km/h
% speed80_ax = subplot(2,3,6);
% pos80_ax = [];
% pos80_ax = [speed80_ax.Position(1), speed80_ax.Position(2), fig_dimension, fig_dimension];
% set(speed80_ax,'Position',pos80_ax);

% subplot('Position',pos80_ax);
axes('Position',pos80_ax);

imshow(fig_to_show);
hold on
x1 = sens_1(1) + R1*sin(t);
y1= sens_1(2) + R1*cos(t);
% plot(x,y,'r');
% fill(sens_1(1),sens_1(2),col1);
patch(x1,y1,col1); hold on;
patch(x2,y2,col2); hold on;
patch(x3,y3,col3); hold on;
patch(x4,y4,col4); hold on;
patch(x5,y5,col5); hold on;
patch(x6,y6,col6); hold on;
title('Speed: 8 km h^{-1}','FontSize',30);