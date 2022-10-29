%% Luigi Raiano, v3, 02-04-2020
marker_size = 40;
fontsize_1 = 50;
fontsize_2 = 50;
linewidth_1 = 5;
%%
cols = []; cols = rand(6,3);
princeton_orange = [255, 143, 0]./255;
pure_blue = [0, 112, 255]./255;

% background_color = [40, 40, 40]./255;
background_color = [1, 1, 1];
%% Plot Sensors (cleaned and non-redundant) over time compared to the spirometer (flow)
subj_chosen = 1;
speed_list = []; speed_list = fieldnames(subjs(subj_chosen).data);

figure;
set(gcf, 'Position', get(0, 'Screensize'));
for i =1:length(speed_list)
    subplot(3,2,i);
    plot(sum(subjs(subj_chosen).data.(speed_list{i}).sensors_reduced.segnale_textile,2),'LineWidth',3,'Color',cols(1,:));
    hold on;
    plot(subjs(subj_chosen).data.(speed_list{i}).bpflt.segnale_spiro,'LineWidth',3,'Color',cols(3,:));
    xlabel('Samples'); ylabel('Breathing Activity'); 
    title(['Non Redundant Sensors - ',num2str(subjs(subj_chosen).data.(speed_list{i}).sensors_reduced.sensors_tokeep)]);
    legend('Sum of Textile','Spirometer Raw');
    set(gca,'FontSize',30);
end

figure;
set(gcf, 'Position', get(0, 'Screensize'));
for i =1:length(speed_list)
    subplot(3,2,i);
    plot(sum(subjs(subj_chosen).data.(speed_list{i}).clean_sensors.segnale_textile,2),'LineWidth',3,'Color',cols(1,:));
    hold on;
    plot(subjs(subj_chosen).data.(speed_list{i}).bpflt.segnale_spiro,'LineWidth',3,'Color',cols(3,:));
    xlabel('Samples'); ylabel('Breathing Activity'); 
    title(['Non Redundant Sensors - ',num2str(subjs(subj_chosen).data.(speed_list{i}).clean_sensors.sensors_tokeep)]);
    legend('Sum of Textile','Spirometer Raw');
    set(gca,'FontSize',30);
end
%% A1 - Plot sensor uses over speed
sensors_perc_use_over_speeds_mat = cell2mat(sensors_perc_use_over_speeds_cell);
speeds = [0,1.6,3,5,6.6,8];
speeds_label = {'0','1.6','3','5','6.6','8'};
sensors_list = {'Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6'};
%
figure;
set(gcf, 'Position', get(0, 'Screensize'));
for i=1:size(sensors_perc_use_over_speeds_mat,1) % loop on sensors
    plot(speeds,sensors_perc_use_over_speeds_mat(i,:),'o-','MarkerSize',marker_size,'LineWidth',linewidth_1,'Color',cols(i,:),...
        'DisplayName',['Sensor ',num2str(i)]);
    hold on
end % end for i
xticks(speeds); xticklabels(speeds_label);
xlim([-0.5,8.5]);
ylim([-1,110]); yticks(0:10:100);
xlabel('Speeds [km/h]'); ylabel('Percentage Use [%]');
grid on;
legend('show','Location','southeast');
title(['Non-Redundant Sensors - \rho = ',num2str(corr_thresh/100)]);
set(gca,'FontSize',fontsize_1);
%% A2 - Plot sensor uses over speed
sensors_clean_perc_use_over_speeds_mat = cell2mat(sensors_clean_perc_use_over_speeds_cell);
speeds = [0,1.6,3,5,6.6,8];
speeds_label = {'0','1.6','3','5','6.6','8'};
sensors_list = {'Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6'};
%
figure;
set(gcf, 'Position', get(0, 'Screensize'));
for i=1:size(sensors_clean_perc_use_over_speeds_mat,1) % loop on sensors
    plot(speeds,sensors_clean_perc_use_over_speeds_mat(i,:),'o-','MarkerSize',marker_size,'LineWidth',linewidth_1,'Color',cols(i,:),...
        'DisplayName',['Sensor ',num2str(i)]);
    hold on
end % end for i 
xticks(speeds); xticklabels(speeds_label);
xlim([-0.5,8.5]);
ylim([-1,110]); yticks(0:10:100);
xlabel('Speeds [km/h]'); ylabel('Percentage Use [%]');
grid on;
legend('show','Location','southeast');
title(['All sensors except noisy ones, \alpha = ',num2str(discard_perc_thres)]);
set(gca,'FontSize',fontsize_1);
%% B1 - Plot the number of sensors used over the speeds
figure;
set(gcf, 'Position', get(0, 'Screensize'));
speeds = [0,1.6,3,5,6.6,8]; speeds_label = {'0','1.6','3','5','6.6','8'};
plot(speeds, n_sensors_used.mean_along_subjects_over_speed,'o-','MarkerSize',marker_size,'LineWidth',linewidth_1,'Color','k','MarkerFaceColor',princeton_orange);
xticks(speeds); xticklabels(speeds_label);
xlim([-0.5,8.5]); ylim([0,6]);
xlabel('Speed [km\cdoth^{-1}]'); ylabel('Mean Sensors Used');
grid on;
% title('Non-Redundant Sensors','FontName','Times New Roman');
title('Selected Sensors');
set(gca,'FontSize',fontsize_1);
%% B2 - Plot the number of sensors used over the speeds
figure;
set(gcf, 'Position', get(0, 'Screensize'));
plot(speeds, n_sensors_clean_used.mean_along_subjects_over_speed,'o-','MarkerSize',marker_size,'LineWidth',linewidth_1,'Color','k');
xticks(speeds); xticklabels(speeds_label);
xlim([-0.5,8.5]); ylim([0,6]);
xlabel('Speed [km\cdoth^{-1}]'); ylabel('Sensors used');
grid on;
title('All sensors except noisy ones');
set(gca,'FontSize',fontsize_1);
%% Plot Best Sensors Configuration over time
subj_chosen = 8;
speed_chosen = 2;
speed_list = []; speed_list = fieldnames(subjs(subj_chosen).data);

best_conf_mean = [];
best_conf_mean = sum(subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.segnale_textile,2);
time = [];
time = subjs(subj_chosen).data.(speed_list{speed_chosen}).best_sensors.tempo_textile;

P_norm = []; freq = []; P = []; f_max = [];
[P_norm, freq, P, f_max] = Perform_PSD_v2(best_conf_mean,srate);

figure;
set(gcf, 'Position', get(0, 'Screensize'));

subplot(2,1,1);
% tiledlayout(2,1);
% nexttile
plot(time,best_conf_mean,'LineWidth',linewidth_1,'Color',pure_blue);
% area(time,best_conf_mean,'FaceColor',pure_blue);
xlabel('time [s]','Interpreter','latex'); ylabel('Piezo [V]','Interpreter','latex');
ylim([-1.2,1.2]);
title('Time Domain','Interpreter','latex');
set(gca,'FontSize',fontsize_2,'color',background_color);

% figure;
subplot(2,1,2);
% nexttile
% plot(freq,P,'LineWidth',linewidth_1,'Color',princeton_orange);
area(freq,P,'FaceColor',princeton_orange);
xlabel('frequency [Hz]','Interpreter','latex'); ylabel('Piezo PSD [$V^2 \cdot Hz^{-1}$]','Interpreter','latex');
xlim([0,2]);
title('Freqeuncy Domain','Interpreter','latex');
set(gca,'FontSize',fontsize_2,'color',background_color);