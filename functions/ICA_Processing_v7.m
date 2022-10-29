function data_out = ICA_Processing_v7(data_in, min_pks_height_imu, min_pks_height_ics, plot_flag)
data = data_in.data;

data_out = [];
data_out = data_in;
%%
srate = data_in.srate;
piezo = data.textile_raw; % BP filtered 0.05-2Hz
acc = data.acc;
gyro = data.gyro;
spiro = data.spirometro_ref;

band_high = 2;

magnification = 1e1;
data_for_ica = [];
data_for_ica = [piezo,gyro].*magnification;
data_for_ica = data_for_ica';
data_out.ica_proc.data_for_ica = data_for_ica;
%%
% prepare for ICA
white=1;
subspace='eigenrnd';
% subspace='lap';
warning(['remeber to scale the signal by ',num2str(magnification)]);
%% Whitening of the data
[Weigenrnd,d]=prepro(data_for_ica,white,subspace);
variance = [];

for i=1:length(Weigenrnd)
    disp(['idx: ' num2str(i), ' Varaince explained: ', num2str(Weigenrnd(i).variance)]);
end
W = [];
W=Weigenrnd(1).mat;
%% RUN ICA
xw=W*data_for_ica;
Winv = [];
Winv=pinv(W);
IC = []; A = []; WB = [];
[IC, A, WB] =fastica(data_for_ica,'g', 'tanh','whiteSig',xw,'whiteMat',W,'dewhiteMat',Winv,'displayMode', 'off');
disp('ICA done!');

data_out.ica_proc.IC = IC;
data_out.ica_proc.A = A;
data_out.ica_proc.WB = WB;
%% PSD
% PSD
win = round(size(IC,2)/1);
nfft = round(size(IC,2)/1);
psd_ic = [];
freq_ic = [];
psd_ic_norm = [];
for i=1:size(IC,1)
    [psd_ic(:,i),freq_ic(:,i)] = pwelch(IC(i,:),win,[],nfft,srate);
    psd_ic_norm(:,i) = psd_ic(:,i)./(max(psd_ic(:,i)));
end % for i

if(strcmp(plot_flag,'plots_on'))
    figure;
    for i=1:size(IC,1)
        subplot(4,3,i)
        plot(freq_ic(:,i),psd_ic(:,i),'LineWidth',3);
        xlabel('Frequency')
        ylabel('PSD norm Ind. Components');
        xlim([0,band_high]);
    end % end for
end

% Spiro
win = round(size(IC,2)/1);
nfft = round(size(IC,2)/1);
psd_spiro = [];
psd_spiro_norm = [];
freq_spiro = [];
[psd_spiro,freq_spiro] = pwelch(spiro,win,[],nfft,srate);
psd_spiro_norm = psd_spiro./(max(psd_spiro));

if(strcmp(plot_flag,'plots_on'))
    figure;
    plot(freq_spiro,psd_spiro,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD Spirometro');
    xlim([0,band_high]);
    title(['Component ',num2str(i),]);
end
%% PSD IMU
imu_data = [acc, gyro];

% PSD
win = round(size(imu_data,1)/1);
nfft = round(size(imu_data,1)/1);
psd_imu = [];
freq_imu = [];
psd_imu_norm = [];
for i=1:size(imu_data,2)
    [psd_imu(:,i),freq_imu(:,i)] = pwelch(imu_data(:,i),win,[],nfft,srate);
%     psd_imu_norm(:,i) = psd_imu(:,i)./(max(psd_imu(:,i)));
end % for i

acc_idx = 1:3;
gyro_idx = 4:6;
for i=acc_idx
    max_psd_acc(i) = max(psd_imu(:,i));
end
max_max_psd_acc = max(max_psd_acc);
psd_imu_norm(:,acc_idx) = psd_imu(:,acc_idx)./max_max_psd_acc;

for i=gyro_idx
    max_psd_gyro(i) = max(psd_imu(:,i));
end
max_max_psd_gyro = max(max_psd_gyro);
psd_imu_norm(:,gyro_idx) = psd_imu(:,gyro_idx)./max_max_psd_gyro;

if(strcmp(plot_flag,'plots_on'))
    figure;
    for i=1:size(psd_imu,2)
        plot(freq_imu(:,i),psd_imu(:,i),'LineWidth',3);
        hold on
    end % for i
    xlabel('Frequency')
    ylabel('PSD Acc');
    title('IMU');
    xlim([0,band_high]);
    xlim([0,band_high]);
    imu_list = {'acc x','acc y','acc z', 'gyro x','gyro y','gyro z'};
    legend(imu_list);
end

if(strcmp(plot_flag,'plots_on'))
    comp_toplot = comps_selected;
    figure;
    plot(freq_ic(:,comp_toplot),psd_ic_norm(:,comp_toplot),'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD norm Ind. Components');
    xlim([0,band_high]);
    xlim([0,band_high]);
end

%% Remove IMU effect v3 -  NEW 31-01-2020
% min_pks_height = 0.8;
k=1;
for i=1:size(psd_imu_norm,2)
    [peaks_imu, idx_pks_imu] = findpeaks(psd_imu_norm(:,i),'MinPeakHeight',min_pks_height_imu);
    
    if(~isempty(idx_pks_imu))
        freq_pks_imu(k).freq = max(freq_imu(idx_pks_imu));
        k = k+1;
    end
end

k = 1;
comps_nok = [];
range_freq = 0.3;
for i=1:size(psd_ic,2)
    peaks_comp_i = [];
    idx_comp_i = [];
    freq_pks_comp_i = [];
    [peaks_comp_i,idx_comp_i] = findpeaks(psd_ic_norm(:,i),'MinPeakHeight',min_pks_height_ics);
    freq_pks_comp_i = freq_ic(idx_comp_i,i);
    j=1;
    imu_artifact_found = false;
    while(j<=length(freq_pks_imu) && imu_artifact_found==false) % fermati appena trovi una frequenza uguale a quella di uno degli imu
        h=1;
        
        freq_picco_imu = [];
        freq_picco_imu = max(freq_pks_imu(j).freq);
        freq_picco_imu_rnd_middle = [];
        freq_picco_imu_rnd_middle = round(freq_picco_imu,2,'decimal');
        freq_picco_imu_range = [];
        freq_picco_imu_range = (freq_picco_imu_rnd_middle - range_freq):1e-2:(freq_picco_imu_rnd_middle + range_freq);
        
        idx = [];
        check_artifact = [];
        check_artifact = ismember(round(freq_pks_comp_i,2,'decimal'),freq_picco_imu_range);
        
        p =1;
        trovato_artifact_range = false;
        check_artifact_2 = [];
        while(p<length(freq_picco_imu_range) && trovato_artifact_range==false)

            ics_pks_rounded = round(freq_pks_comp_i,2,'decimal');
            
            
            check_artifact_2 = ismembertol(ics_pks_rounded,freq_picco_imu_range(p));
            
            idx_2 = find(check_artifact_2==1);
            
            if(~isempty(idx_2))
                trovato_artifact_range = true;
                imu_artifact_found = true;
                comps_nok(k) = i;
                k = k+1;
            else
                p = p+1;
            end
           
        end 
        
        j = j+1;
    end % end while j
end % end for i
comps_selected = [];
all_comps = 1:size(IC,1);
comps_selected = setdiff(all_comps,comps_nok);

data_out.ica_proc.freqs_imu = freq_pks_imu;
data_out.ica_proc.comps_selected = comps_selected;
%% Reconstruct signal
xRec = [];
if(isnumeric(comps_selected))
    xRec=A(:,comps_selected)*IC(comps_selected,:);
end

piezo_rec = xRec(1:6,:)./magnification; piezo_rec = piezo_rec';
%% PSD and Plot reconstructed
win = round(size(piezo_rec,1)/1);
nfft = round(size(piezo_rec,1)/1);
freq_piezo_rec_ave = [];
psd_piezo_rec_ave = [];
psd_piezo_rec_ave_norm = [];
[psd_piezo_rec_ave,freq_piezo_rec_ave] = pwelch(mean(piezo_rec,2),win,[],nfft,srate);
psd_piezo_rec_ave_norm = psd_piezo_rec_ave./(max(psd_piezo_rec_ave));

win = round(size(piezo_rec,1)/1);
nfft = round(size(piezo_rec,1)/1);
freq_piezo_rec = [];
psd_piezo_rec = [];
psd_piezo_rec_norm = [];
for i=1:size(piezo_rec,2)
    [psd_piezo_rec(:,i),freq_piezo_rec(:,i)] = pwelch(piezo_rec(:,i),win,[],nfft,srate);
    psd_piezo_rec_norm(:,i) = psd_piezo_rec(:,i)./(max(psd_piezo_rec(:,i)));
end

win = round(size(piezo,1)/1);
nfft = round(size(piezo,1)/1);
freq_piezo_ave = [];
psd_piezo_ave = [];
psd_piezo_ave_norm = [];
[psd_piezo_ave,freq_piezo_ave] = pwelch(mean(piezo,2),win,[],nfft,srate);
psd_piezo_ave_norm = psd_piezo_ave./(max(psd_piezo_ave));

win = round(size(piezo_rec,1)/1);
nfft = round(size(piezo_rec,1)/1);
freq_piezo = [];
psd_piezo = [];
psd_piezo_norm = [];
for i=1:size(piezo,2)
    [psd_piezo(:,i),freq_piezo(:,i)] = pwelch(piezo(:,i),win,[],nfft,srate);
    psd_piezo_norm(:,i) = psd_piezo(:,i)./(max(psd_piezo(:,i)));
end
%% Save data
data_out.ica_proc.info1 = 'Below all data useful to make plot';

data_out.ica_proc.info2 = 'PSD ICs';
data_out.ica_proc.freq_ic = freq_ic;
data_out.ica_proc.psd_ic = psd_ic;
data_out.ica_proc.psd_ic_norm = psd_ic_norm;

data_out.ica_proc.info3 = 'PSD Spirometer';
data_out.ica_proc.freq_spiro = freq_spiro;
data_out.ica_proc.psd_spiro = psd_spiro;
data_out.ica_proc.psd_spiro_norm = psd_spiro_norm;

data_out.ica_proc.info4 = 'PSD IMU BP filtered 0.05-2 Hz ([accx,accy,accz,gyroz,gyroy,gyroz])';
data_out.ica_proc.freq_imu = freq_imu;
data_out.ica_proc.psd_imu = psd_imu;
data_out.ica_proc.psd_imu_norm = psd_imu_norm;

data_out.ica_proc.info5 = 'PSD Piezo Mean BP filtered 0.05-2 Hz';
data_out.ica_proc.freq_piezo_ave = freq_piezo_ave;
data_out.ica_proc.psd_piezo_ave = psd_piezo_ave;
data_out.ica_proc.psd_piezo_ave_norm = psd_piezo_ave_norm;

data_out.ica_proc.info6 = 'PSD Piezo Rec Mean BP filtered 0.05-2 Hz';
data_out.ica_proc.freq_piezo_rec_ave = freq_piezo_rec_ave;
data_out.ica_proc.psd_piezo_rec_ave = psd_piezo_rec_ave;
data_out.ica_proc.psd_piezo_rec_ave_norm = psd_piezo_rec_ave_norm;

data_out.ica_proc.info7 = 'PSD Piezo BP filtered 0.05-2 Hz';
data_out.ica_proc.freq_piezo = freq_piezo;
data_out.ica_proc.psd_piezo = psd_piezo;
data_out.ica_proc.psd_piezo_norm = psd_piezo_norm;

data_out.ica_proc.info8 = 'PSD Piezo Rec BP filtered 0.05-2 Hz';
data_out.ica_proc.freq_piezo_rec = freq_piezo_rec;
data_out.ica_proc.psd_piezo_rec = psd_piezo_rec;
data_out.ica_proc.psd_piezo_rec_norm = psd_piezo_rec_norm;
%% Plots
if(strcmp(plot_flag,'plots_on'))
    figure;
    subplot(1,3,1)
    plot(freq_piezo_rec_ave,psd_piezo_rec_ave,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD');
    title('ICA Rec - Ave Txtile Sensors');
    xlim([0,band_high]);
    
    subplot(1,3,2)
    plot(freq_piezo_ave,psd_piezo_ave,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD');
    title('Raw - Ave Txtile Sensors');
    xlim([0,band_high]);
    
    subplot(1,3,3)
    plot(freq_spiro,psd_spiro,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD');
    title('Spirometer');
    xlim([0,band_high]);
    
    figure;
    subplot(1,3,1)
    plot(freq_piezo_rec_ave,psd_piezo_rec_ave_norm,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD normalized');
    title('ICA Rec - Ave Txtile Sensors');
    xlim([0,band_high]);
    
    subplot(1,3,2)
    plot(freq_piezo_ave,psd_piezo_ave_norm,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD normalized');
    title('Raw - Ave Txtile Sensors');
    xlim([0,band_high]);
    
    subplot(1,3,3)
    plot(freq_spiro,psd_spiro_norm,'LineWidth',3);
    xlabel('Frequency')
    ylabel('PSD normalized');
    title('Spirometer');
    xlim([0,band_high]);
end
end