function [freq_Hz,freq_bpm] = PSD(data,samp)
[P_ref,f_ref] = pwelch(data,round(length(data)/2),[],round(length(data)/2),samp);
P_ref=P_ref/max(P_ref);
[r c] = max(P_ref);
freq_Hz=f_ref(c);
freq_bpm=60*f_ref(c);
plot(f_ref,P_ref,'LineWidth',2);
ylabel('nPSD F');
xlabel('f [Hz]')
xlim([0 2]); ylim([0 1.3]);
set(gca,'Fontsize',14)
end