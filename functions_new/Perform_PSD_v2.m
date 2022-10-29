%% Luigi Raiano, v2, 15/11/2019
% Perform PSD using PWealch and find peaks
% PSD is performed using pwealch with:
%   - length of the window: 5000 samples -> 20 s
%   - overlap equal to 50%
%   - length of the fft: 5000 samples -> 20 s
%
%%
function [P_norm, freq, P, f_max] = Perform_PSD_v2(data,srate)
% PSD: window length and FFT length: round(length(data)/3), no overlap

% [P,freq] = pwelch(data,5000,[],5000,srate);
[P,freq] = pwelch(data,round(length(data)/1),[],round(length(data)/1),srate);
[P_max, idx_max] = max(P);
P_norm=P./P_max;

f_max=freq(idx_max); % frequency of the maximal peak
% f_max_bpm=60*freq(idx_max);
end