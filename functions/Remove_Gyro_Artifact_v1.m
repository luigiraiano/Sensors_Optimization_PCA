function [piezo_data_new, freq_toarx_rotation_out] = Remove_Gyro_Artifact_v1(piezo_data,gyro_y,srate)
%% Power spectrum of piezo datum
[pow_spectr_piezo,freq_piezo] = pwelch(piezo_data,round(length(piezo_data)/2),[],round(length(piezo_data)/2),srate);
P_norm_piezo=pow_spectr_piezo./max(pow_spectr_piezo);

% find peaks
[piezo_peaks,idx_peaks_piezo] = findpeaks(pow_spectr_piezo);
freq_piezo_peaks = freq_piezo(idx_peaks_piezo);
% Select only frequencies below 2Hz
freq_piezo_peaks_tmp = freq_piezo_peaks(freq_piezo_peaks < 2);
%% Power spectrum of gyro y datum
[pow_spectr_gyroy,freq_gyroy] = pwelch(gyro_y,round(length(gyro_y)/2),[],round(length(gyro_y)/2),srate);
P_norm_gyro = pow_spectr_gyroy./max(pow_spectr_gyroy);

% Find peaks. Select only all those peaks whose power contributiion is above the 70% on
% the signal
[gyro_peaks,idx_peaks_gyro] = findpeaks(P_norm_gyro,'MinPeakHeight',0.7);
freq_gyro_peak = freq_piezo(idx_peaks_gyro);
%% prova plot
figure;
subplot(2,1,1)
plot(freq_piezo,P_norm_piezo); title('Piezo'); xlabel('freq'); xlim([0,2]);
hold on
plot(freq_piezo_peaks, P_norm_piezo(idx_peaks_piezo),'o');
subplot(2,1,2)
plot(freq_gyroy,P_norm_gyro); title('Gyro'); xlabel('freq'); xlim([0,2]);
hold on
plot(freq_gyro_peak,P_norm_gyro(idx_peaks_gyro),'o');
%% Search common frequencies between the two signals
freq_toarx_rotation = [];
for i=1:length(freq_piezo_peaks_tmp)
    if(freq_piezo_peaks_tmp(i) == freq_gyro_peak)
        freq_toarx_rotation = freq_piezo_peaks_tmp(i);
    end % end if
end % end for i

%% Remove torax rotation artifact
if(~isempty(freq_toarx_rotation))
    wo = freq_toarx_rotation/(srate/2);  bw = wo/35;
    [b,a] = iirnotch(wo,bw);
    piezo_data_new = filtfilt(b,a,piezo_data);
    freq_toarx_rotation_out = freq_toarx_rotation;
else
    piezo_data_new = piezo_data;
    freq_toarx_rotation_out = -1000;
end % end if
%% prova plot
[pow_spectr_piezo_new,freq_piezo_new] = pwelch(piezo_data_new,round(length(piezo_data)/2),[],round(length(piezo_data)/2),srate);
P_norm_piezo_new=pow_spectr_piezo_new./max(pow_spectr_piezo_new);

figure;
subplot(2,1,1)
plot(freq_piezo_new,P_norm_piezo_new); title('Piezo notch filtered'); xlabel('freq'); xlim([0,2]);
hold on
plot(freq_piezo_peaks, P_norm_piezo(idx_peaks_piezo),'o');
subplot(2,1,2)
plot(freq_gyroy,P_norm_gyro); title('Gyro'); xlabel('freq'); xlim([0,2]);
hold on
plot(freq_gyro_peak,P_norm_gyro(idx_peaks_gyro),'o');
end % end function