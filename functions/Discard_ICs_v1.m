%% Luigi Raiano, v1, 15/11/2019
% Discard Components on the basis of the PSD
% The component is discarded if the PSD has an armonic higher than 0.9 Hz
% that weights at least the 40% on the amplitude
%
%%
function discarded = Discard_ICs_v1(freq,P_norm)

discarded = false;
[peaks,idx] = findpeaks(P_norm);

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
    discarded = true;
end

end