folder = 'immagini_bland_altman';
static_folder = [folder,filesep,'Statica'];
dynamic_folder = [folder,filesep,'Dinamica'];

sel_vs_ref = 'PCA_nonred vs REF';
dt_vs_ref = 'SG vs REF';
gpc_vs_ref = 'BEST vs REF';

confs = [];
confs = {sel_vs_ref,dt_vs_ref,gpc_vs_ref};
speed_folder = {static_folder,dynamic_folder};
%%
for k = 1:length(speed_folder)
    
    for j = 1:length(confs)
        files_all = [];
        files_all=dir([speed_folder{k},filesep,confs{j},'/*.fig']);
        
        % discard hidden files
        count = 1;
        clear figs;
        
        for i = 1:length(files_all)
            if(~files_all(i).isdir && ~strcmp(files_all(i).name(1), '.') && strcmp(files_all(i).name(1:2),'ba'))
                figs(count) = files_all(i);
                count = count + 1;
            end % end if
            
        end % end for i
        
        for n = 1:length(figs)
            hfig = [];
            hfig = openfig([speed_folder{k},filesep,confs{j},filesep,figs(n).name]);
%             set(hfig, 'Position', get(0, 'Screensize'));
%             set(gca,'FontSize',24);
            saveas(hfig, [speed_folder{k},filesep,confs{j},filesep,strcat(figs(n).name(1:end-4))],'epsc');
%             saveas(hfig, [speed_folder{k},filesep,confs{j},filesep,strcat(figs(n).name(1:end-4)),'.pdf']);
            close(hfig);
        end % end for n
        
    end % end for j
    
end % end for k
%%
