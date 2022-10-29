% Run PSD without normalizing the spectrum
%
function [freq_max_Hz, discard] = PSD_v3(data,samp,condition,plot_status)
discard = false;

% PSD: window length and FFT length: round(length(data)/2), no overlap
[Pspctr,freq] = pwelch(data,round(length(data)/2),[],round(length(data)/2),samp);
P_norm=Pspctr/max(Pspctr);
[max_val,idx_max] = max(Pspctr);

freq_max_Hz=freq(idx_max); % frequency of the maximal peak
% freq_bpm=60*freq(idx_max);

if(strcmp(plot_status,'plotdata'))
    plot(freq,P_norm,'Color',rand(3,1),'LineWidth',3);
    xlabel('Frequency [Hz]'); ylabel('PSD normalized');
%     ylim([0,1.3]);
    ylim([0,1.3]); xlim([0 2]);
end


[peaks,idx] = findpeaks(P_norm);

if(strcmp(condition,'discard_channels'))
    ratio_thres = 0.4;
    freq_thres = 1.2; % [Hz]
    high_freqs = [];
    k = 1;
    for i=1:length(peaks)
        if( (peaks(i) >= ratio_thres) & (freq(idx(i)) >= freq_thres) )
            high_freqs(k) = freq(idx(i));
            k = k+1;
        end % end if
    end % end for i
    
    if(~isempty(high_freqs))
        discard = true;
    end
elseif(strcmp(condition,'discard_ica'))
    ratio_thres = 0.40;
    freq_thres = 0.9; % [Hz]
    
    high_freqs = [];
    k = 1;
    for i=1:length(peaks)
        if( (peaks(i) >= ratio_thres) & (freq(idx(i)) >= freq_thres) )
            high_freqs(k) = freq(idx(i));
            k = k+1;
        end % end if
    end % end for i
    
    if(~isempty(high_freqs))
        discard = true;
    end
elseif(strcmp(condition,'no_discard'))
    discard = false;
end % end if

end