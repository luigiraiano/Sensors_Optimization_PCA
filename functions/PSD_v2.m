% Run PSD without normalizing the spectrum
%
function [freq_Hz,freq_bpm] = PSD_v2(data,samp)
[P_ref,f_ref] = pwelch(data,round(length(data)/2),[],round(length(data)/2),samp);
% P_ref=P_ref/max(P_ref);
[max_val,idx_max] = max(P_ref);
freq_Hz=f_ref(idx_max);
freq_bpm=60*f_ref(idx_max);
plot(f_ref,P_ref,'LineWidth',2);
ylabel('nPSD F');
xlabel('f [Hz]')
xlim([0 2]); ylim([0,(max_val+0.1)]);
set(gca,'Fontsize',14);
end