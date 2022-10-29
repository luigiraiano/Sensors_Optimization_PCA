%% Luigi Raiano, v1, 15/11/2019
% Perform PSD using PWealch and find peaks
% PSD is performed using pwealch with:
%   - length of the window: round(length(data)/2)
%   - overlap equal to 50%
%   - length of the fft: round(length(data)/2)
%
%%
function [P_norm, freq, P, f_peaks] = Perform_PSD_v1(data,srate)
discard = false;

% PSD: window length and FFT length: round(length(data)/2), no overlap
[P,freq] = pwelch(data,round(length(data)/2),[],round(length(data)/2),srate);
% [P,freq] = pwelch(data,round(length(data)/2),[],length(data),srate);
[P_max, idx_max] = max(P);
P_norm=P./P_max;

f_max=freq(idx_max); % frequency of the maximal peak
% freq_bpm=60*freq(idx_max);

[peaks,idx] = findpeaks(P_norm);

[P_peaks,P_peaks_idx] = findpeaks(P_norm,'MinPeakHeight',0.5);
f_peaks = freq(P_peaks_idx); % [Hz]
end