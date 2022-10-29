%% tabella I supp mat
path_folde_tbls = 'Tabelle_Latex';
if(exist(path_folde_tbls)~=7) % create new folder if it does not exist
    mkdir(path_folde_tbls);
end

tabl_latex_file = [path_folde_tbls, filesep,'tabella_latex_supp_mat.txt'];
fid=fopen(tabl_latex_file,'w');  %% open file writing mode (clear any existing content; use 'at' to keep existing content instead)
tbl_to_save = [];
tbl_to_save = pca_vs_spiro_frq_ass.DeltaF.e_spiro_pca_bpm_overspeed_ave;
speed_list = {'0','1.6','3.0','5.0','6.6','8.0'};

fprintf(fid,'\\toprule \n');
fprintf(fid,['\\textbf{ \\textit{Speed}} ($j$) [$km \\cdot h^{-1}$]',' \t&\t', '$ \\tensor[^{j}]{{ \\tilde{ \\vect{F}}}}{_{}^{}}  \\ [bpm] $','\t&\t','$\\tensor[^{j}]{{\\vect{ p } }}{_{}^{}}$','\\\\',' \n']);
fprintf(fid,'\\midrule \n');
for i=1:length(tbl_to_save)
    fprintf(fid,['%3s', '\t&\t',' %4.2f', '\\textpm','%4.2f', '\t &\t', '%4.2f', '\\textpm','%4.2f', '\\\\',' \n'],...
        speed_list{i},...
        round(pca_vs_spiro_frq_ass.DeltaF.e_spiro_pca_bpm_overspeed_ave(i),2),...
        round(pca_vs_spiro_frq_ass.DeltaF.e_spiro_pca_bpm_overspeed_sd(i),2),...
        round(n_pcs_overspeed_ave(i),2),...
        round(n_pcs_overspeed_sd(i),2));
end % end for i
fprintf(fid,'\\bottomrule \n');
fclose(fid);

type(tabl_latex_file);
%% tabella I paper
path_folde_tbls = 'Tabelle_Latex';
if(exist(path_folde_tbls)~=7) % create new folder if it does not exist
    mkdir(path_folde_tbls);
end

tabl_latex_file = [path_folde_tbls, filesep,'tabella_latex_f_sg_err.txt'];
fid=fopen(tabl_latex_file,'w');  %% open file writing mode (clear any existing content; use 'at' to keep existing content instead)
tbl_to_save = [];
tbl_to_save = pca_vs_spiro_frq_ass.DeltaF.e_spiro_pca_bpm_overspeed_ave;
speed_list = {'0','1.6','3.0','5.0','6.6','8.0'};

fprintf(fid,'\\toprule \n');
fprintf(fid,['\\textbf{\textit{Speed}} & $\\vect{ \\tilde{F} } {^{\\vect{X}^{sel}}} \\, [bpm]$ & ${{\\vect{ \\tilde{F} } }}{^{\\vect{X}^{DT}}} \\, [bpm]$ & ${{ \\vect{ \\tilde{F} } }}{^{\\vect{X}^{GPC}}} \\, [bpm]$\\\\',' \n']);
fprintf(fid,'\\midrule \n');
for i=1:length(tbl_to_save)
    fprintf(fid,['%3s', '\t&\t',' %4.2f', '\\textpm','%4.2f','\t&\t',' %4.2f', '\\textpm','%4.2f', '\t &\t', '%4.2f', '\\textpm','%4.2f', '\\\\',' \n'],...
        speed_list{i},...
        round(textile_vs_spiro_frequency_assessment.DeltaF.e_spiro_nonred_bpm_overspeed(i),2),...
        round(textile_vs_spiro_frequency_assessment.DeltaF.e_spiro_nonred_bpm_overspeed_sd(i),2),...
        round(textile_vs_spiro_frequency_assessment.DeltaF.e_spiro_ref_bpm_overspeed(i),2),...
        round(textile_vs_spiro_frequency_assessment.DeltaF.e_spiro_ref_bpm_overspeed_sd(i),2),...
        round(textile_vs_spiro_frequency_assessment.DeltaF.e_spiro_best_bpm_overspeed(i),2),...
        round(textile_vs_spiro_frequency_assessment.DeltaF.e_spiro_best_bpm_overspeed_sd(i),2))
end % end for i
fprintf(fid,'\\bottomrule \n');
fclose(fid);
%% Tabella Supp Mat per selected sensors consistency (section G1 del mail_Elab)
% 1 tabella per ongi speed
% per ogni speed, tutti i soggetti
% per ogni soggetto tutti i sensori selezionati

CLK=clock;
YR=num2str(CLK(1),'%04d');
MTH=num2str(CLK(2),'%02d');
DAY=num2str(CLK(3),'%02d');
HOUR=num2str(CLK(4),'%02d');
MIN=num2str(CLK(5),'%02d');
SEC=num2str(round(CLK(6)),'%02d');
date_time = [YR,'-',MTH,'-',DAY,'_',HOUR,'.',MIN];

% f_err_bpm_cell & sel_senrs_id_cell;
n_subjs = size(f_err_bpm_cell,1);
n_speeds = size(f_err_bpm_cell,2);

speed_list = {'0','1.6','3.0','5.0','6.6','8.0'};

path_folder_tbls = [];
path_folder_tbls = 'Tabelle_Latex';
if(exist(path_folder_tbls)~=7) % create new folder if it does not exist
    mkdir(path_folder_tbls);
end

% for j = 1:n_speeds %loop per velovità -> salva un file diverso per ogni speed
%     tab_sel_sens_consistency_file = [];
%     tab_sel_sens_consistency_file = [path_folder_tbls,filesep,'selSensCons_speed',num2str(j),'_',date_time];
%     
%     fid = [];
%     fid=fopen(tab_sel_sens_consistency_file,'w');  %% open file writing mode (clear any existing content; use 'at' to keep existing content instead)
%     fprintf(fid,'\\toprule \n');
%     fprintf(fid,['\\textbf{\textit{Subjects}} & $\\vect{ \\tilde{F} } {^{S1}} \\, [bpm]$ & $\\vect{ \\tilde{F} } {^{S2}} \\, [bpm]$,', '$\\vect{ \\tilde{F} } {^{S3}} \\, [bpm]$', '$\\vect{ \\tilde{F} } {^{S4}} \\, [bpm]$', '$\\vect{ \\tilde{F} } {^{S5}} \\, [bpm]$','$\\vect{ \\tilde{F} } {^{S6}} \\, [bpm]$\\\', '\n']);
%     fiprintf(fid, '\\midrule \n');
%     fiprintf(fid, '\\multicolumn{4}{l}{\\textit{\\textit{Speed: 0 kmh}}}\\\ \n');
% end % end for j


for j = 1:n_speeds %loop per velovità
    disp(['/* ------ Speed: ', speed_list{j} '------ */']);
    for i=1:n_subjs
        disp(['%%%%%%% Subject: ', num2str(i),' - Sensors Selected: ', num2str(sel_senrs_id_cell{i,j}), ' %%%%%%%']);
        to_disp = [];
        to_disp = num2str(i);
%         to_disp = [ num2str(i), ' & ,' num2str( f_err_bpm_cell{i,j} ) ]; 
        for k = 1:length(f_err_bpm_cell{i,j}) % # of sensors  
            to_disp = [to_disp, ' & ', 'S_', num2str(sel_senrs_id_cell{i,j}(k) ), ' = ', num2str( f_err_bpm_cell{i,j}(k) )];
        end
        
        disp(to_disp);
        disp('');
    end % end for i
end % end for j