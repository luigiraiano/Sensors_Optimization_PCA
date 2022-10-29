%% Luigi Raiano, v1, 27/10/2019
%
% This function aims at evaluating the breathing frequency.
% With respect PSD_v3, this function does not implement the discarding
% function and and moreover it does not return the breathing frequency by
% measuring the frequency at the maximal peak of the PSD, but it measures
% the peaks instead. In fact, during walking or running, the subject may
% change the breathing frequency in order to adapt to the task.
% For this reson, do not use this function beafore having cleaned the
% signal.
%
%%
function breath_freq = Get_Mean_Breathing_Rate_v1(data,srate,thres)
% PSD: window length and FFT length: round(length(data)/2), no overlap
[powsd,freq] = pwelch(data,round(length(data)/2),[],round(length(data)/2),srate);
psd_norm=powsd/max(powsd);

% Find peaks with a weight higher than the (thresh*100)% of the whole signal
[peaks,idx] = findpeaks(psd_norm,'MinPeakHeight',thres);

breath_freq = freq(idx);
end