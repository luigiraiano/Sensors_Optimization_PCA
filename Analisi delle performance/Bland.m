function [ media_vett, diff, mod, loa1, loa2, amp_loa, fitresult, gof] = Bland( vettore,a,b)
%in frequenza:[ media_vett, diff, mod, loa1, loa2, amploa, gof, fitresult ] = Bland( 60./totali )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

media_vett=(vettore(:,1)+vettore(:,2))/2;
diff=(vettore(:,1)-vettore(:,2));
mod=mean(diff);
loa1=mod+(1.96*std(diff));
loa2=mod-(1.96*std(diff));
amp_loa=(loa1-(loa2))/2;

% plot([0 max(vettore(:,2))+min(vettore(:,2))],[mod mod], 'k-','linewidth',2)
% hold on
% plot([0 max(vettore(:,2))+min(vettore(:,2))],[loa1 loa1], 'r-','linewidth',2)
% plot([0 max(vettore(:,2))+min(vettore(:,2))],[loa2 loa2], 'b-','linewidth',2)
 plot(media_vett,diff,b,'MarkerSize',8,'linewidth',1,'MarkerEdgeColor','k','MarkerFaceColor',a)
% legend('Bias','Bias+1.96SD', 'Bias-1.96SD')
title('BA analysis')
% ylim([-10 10])
% xlim([0 max(vettore(:,2))+min(vettore(:,2))])
set(gca,'FontSize',16)
xlabel('f_{R mean}  [bpm]')
ylabel('\Deltaf_{R} [bpm]')
hold on

% figure(2)
% plot(vettore(:,2), vettore(:,1), '.')
% [p,S]=polyfit(vettore(:,2), vettore(:,1),1)
% yt=polyval(p,vettore(:,2))
% hold on
% plot(vettore(:,2), yt)
[xData, yData] = prepareCurveData( vettore(:,2), vettore(:,1) );
% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Lower = [-Inf 0];
[fitresult, gof] = fit( xData, yData, ft, opts );
% Plot fit with data.
% h = plot( fitresult, xData, yData,'ko')
% legend( h, 'Experimental values', 'Linear interpolation', 'Location', 'NorthEast' );
% xlabel ('T_{reference} [s]')
% ylabel ('T_{Smart textile} [s]')
% set(gca,'FontSize',16)


end

