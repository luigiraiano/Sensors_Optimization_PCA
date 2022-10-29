function [spiro_vs_piezoraw, spiro_vs_piezoclean] = Assess_ICABased_Algorithm_Performance_v1(data)
%%
freq_ic = data.freq_ic;
psd_ic = data.psd_ic;
psd_ic_norm = data.psd_ic_norm;

freq_spiro = data.freq_spiro;
psd_spiro = data.psd_spiro;
psd_spiro_norm = data.psd_spiro_norm;

freq_imu = data.freq_imu;
psd_imu = data.psd_imu;
psd_imu_norm = data.psd_imu_norm;

freq_piezo_ave = data.freq_piezo_ave;
psd_piezo_ave = data.psd_piezo_ave;
psd_piezo_ave_norm = data.psd_piezo_ave_norm;

freq_piezo_rec_ave = data.freq_piezo_rec_ave;
psd_piezo_rec_ave = data.psd_piezo_rec_ave;
psd_piezo_rec_ave_norm = data.psd_piezo_rec_ave_norm;

freq_piezo = data.freq_piezo;
psd_piezo = data.psd_piezo;
psd_piezo_norm = data.psd_piezo_norm;

freq_piezo_rec = data.freq_piezo_rec;
psd_piezo_rec = data.psd_piezo_rec;
psd_piezo_rec_norm = data.psd_piezo_rec_norm;
%% Assessment of frequency
% Get the frequency on spiromenter and on signals (reconstructed and non).
% Check if the peack are the same. Set a peak above the 0.5 % of the
% amplitude of the normalized PSD
min_pks_height = 0.6;
%% Find Peaks of the Spiro
[pks_spiro, idx_pks_spiro] = findpeaks(psd_spiro_norm,'MinPeakHeight',min_pks_height);
f_pks_spiro = freq_spiro(idx_pks_spiro);

%% Find Peaks of the Piezo data (BP filtered)
[pks_piezo_raw, idx_piezo_raw] = findpeaks(psd_piezo_ave_norm,'MinPeakHeight',min_pks_height);
f_pks_piezo_raw = freq_spiro(idx_piezo_raw);

%% Find Peaks of the Piezo cleaned
[pks_piezo_clean, idx_piezo_clean] = findpeaks(psd_piezo_rec_ave_norm,'MinPeakHeight',min_pks_height);
f_pks_piezo_clean = freq_spiro(idx_piezo_clean);

%% Comparisons
spiro_vs_piezoraw = isequal(f_pks_spiro,f_pks_piezo_raw);
spiro_vs_piezoclean = isequal(f_pks_spiro,f_pks_piezo_clean);

if(isempty(spiro_vs_piezoraw))
    spiro_vs_piezoraw = 0;
end
if(isempty(spiro_vs_piezoclean))
    spiro_vs_piezoclean = 0;
end
end