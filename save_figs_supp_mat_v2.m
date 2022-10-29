folder = 'immagini_bland_altman_v2';

sel_vs_ref = 'PCA_nonred vs REF';
dt_vs_ref = 'SG vs REF';
gpc_vs_ref = 'BEST vs REF';

confs = [];
confs = {sel_vs_ref,dt_vs_ref,gpc_vs_ref};
figs_names = {'sel_vs_ref', 'dt_vs_ref', 'gpc_vs_ref'};

speed_list = {'0 km\cdoth^{-1}','1.6 km\cdoth^{-1}','3.0 km\cdoth^{-1}','5.0 km\cdoth^{-1}','6.6 km\cdoth^{-1}','8.0 km\cdoth^{-1}'};
%%
for j = 1:length(confs)
    files_all = [];
    files_all=dir([folder,filesep,confs{j},'/*.fig']);
    
    % discard hidden files
    count = 1;
    clear figs;
    
    for i = 1:length(files_all)
        if(~files_all(i).isdir && ~strcmp(files_all(i).name(1), '.') && strcmp(files_all(i).name(1:2),'ba'))
            figs(count) = files_all(i);
            count = count + 1;
        end % end if
        
    end % end for i
    
    hfig = [];
    for n=1:length(figs)
        hfig(n)=hgload([folder,filesep,confs{j},filesep,figs(n).name]); 
        if(n==1)
            title('0 km\cdoth^{-1}');
        end % end if
    end
    
    hfig2 = figure;
    hsub = [];
    for n=1:length(figs)
        hsub(n) = subplot(6,1,n);
        
        copyobj(allchild(get(hfig(n),'CurrentAxes')), hsub(n) );
        ylim([-15,30]);
        if(n==1)
            xlim([0,22]);
        elseif(n==2)
            xlim([0,50])
        end 
        title(speed_list{n});
%         if( (n==5) || (n==6) )
%             xlabel('f_{R mean} [bpm]');
%         end

        if(n==6)
            xlabel('f_{R mean} [bpm]');
        end

        ylabel('\Deltaf_{R} [bpm]');
%         set(gca,'FontSize',28,'PlotBoxAspectRatio',[1,0.5,0.5]);
%         set(gca,'FontSize',28,'DataAspectRatio',[6.200545702592085,22.5,1],'PlotBoxAspectRatio',[2.41914191419142,1,1]);
        %             saveas(hfig, [folder,filesep,confs{j},filesep,strcat(figs(n).name(1:end-4)),'.pdf']);
%         set(gca,'FontSize',28,'DataAspectRatio',[6.200545702592085,22.5,1],'PlotBoxAspectRatio',[2.41914191419142,1,1]);

        set(hsub(n),'FontSize',28,'Position',(get(gca,'Position')+[0,0,0,0.0005]) );
        if(n==1)
            legend('Vol. 1','Vol. 3','Vol. 3','Vol. 4','Vol. 5','Vol. 6','Vol. 7','Vol. 8','Vol. 9','Vol. 10','FontSize',26,'Location','northeastoutside'); % 'Location','northeastoutside'
%               legend('S1','S3','S3','S4','S5','S6','S7','S8','S9','S10','FontSize',24); % 'Location','northeastoutside'
        end
    end
    
    set(hfig2, 'Position', get(0, 'Screensize'));
    
%     saveas(hfig2, [folder,filesep,confs{j}],'epsc');
    savefig(hfig2, [folder,filesep,figs_names{j},'_legend.fig']);
    close all
    
end % end for j