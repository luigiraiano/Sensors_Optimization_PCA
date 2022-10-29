function [fatto_garment_Hz fatto_garment_bpm segnale_textile_RT_Filt_W_6segnali] = valutapsd(segnale_textile_RT_Filt_W_6segnali,plot_flag)

P2=[];
f_garment=[];
P_garment=[];

% clearvars P2
% clearvars f_garment
% clearvars P_garment

srate = 250;
[P_garment,f_garment] = pwelch(segnale_textile_RT_Filt_W_6segnali,round(length(segnale_textile_RT_Filt_W_6segnali)/1),[],round(length(segnale_textile_RT_Filt_W_6segnali)/1),srate);
% [P_garment,f_garment] = pwelch(segnale_textile_RT_Filt_W_6segnali,5000,[],5000,250);
P2=P_garment;

if(plot_flag)
    figure('Renderer', 'painters', 'Position', [300 90 300 300]);
    plot(f_garment,P2,'LineWidth',2);
    ylabel('PSD SG');
    xlabel('f [Hz]')
    xlim([0 2]);
    set(gca,'Fontsize',14)
end


P_max = max(P2);
[m, i_min] = min(P_max);
[M, i_max] = max(P_max);

if i_min<i_max
    P2(:,i_max)=[];
    P2(:,i_min)=[];
    segnale_textile_RT_Filt_W_6segnali(:,i_max)=[];
    segnale_textile_RT_Filt_W_6segnali(:,i_min)=[];
    
else
    P2(:,i_min)=[];
    P2(:,i_max)=[];
    segnale_textile_RT_Filt_W_6segnali(:,i_min)=[];
    segnale_textile_RT_Filt_W_6segnali(:,i_max)=[];
end

if(plot_flag)
    figure('Renderer', 'painters', 'Position', [300 90 300 300]);
    plot(f_garment,P2(:,:),'LineWidth',2);
    ylabel('PSD SG');
    xlabel('f [Hz]');
    set(gca,'Fontsize',16);
    xlim([0 2]);
end

if(plot_flag)
    figure('Renderer', 'painters', 'Position', [300 90 300 300]);
    plot(f_garment,mean(P2,2)/max(mean(P2,2)),'k-','LineWidth',2);
    ylabel('nPSD SG');
    xlabel('f [Hz]');
    xlim([0 2]);
    set(gca,'Fontsize',16);
end

P_mean = mean(P2,2)/max(mean(P2,2));
[M_P_mean, I_P_mean] = max(P_mean);
fatto_garment_Hz = f_garment(I_P_mean);
fatto_garment_bpm=60*fatto_garment_Hz;


end

