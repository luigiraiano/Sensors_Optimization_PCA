%% Luigi Raiano, v1, 02-06-2020
%%
function out = DeltaF_PCAvsSpiro_v2(subjs_in)

out = [];
% frequenza max psd per piezo e flow e determina la differenza (calcolata
% come frequenza massima della PSD media dei sensori, n_sensors >1 )

% Segnali PCA (subset of components to account for the 95% of the total
% variance)
f_pca = []; f_pca_bpm = [];

% Spirometro
f_spiro = []; f_spiro_bpm = [];

% Errori
% spiro - pca
e_spiro_pca = []; e_spiro_pca_bpm = [];
e_spiro_oldanalysis = [];

for i=1:length(subjs_in) % loop su soggetti
    speed_list = fieldnames(subjs_in(i).data);
    
    for j=1:length(speed_list) % loop su speed
        
        % Segnali pca
        f_pca(i,j) = subjs_in(i).data.(speed_list{j}).PCA.f_pca;
        f_pca_bpm(i,j) = subjs_in(i).data.(speed_list{j}).PCA.fbpm_pca;
        f_sg_old(i,j) = subjs_in(i).data.(speed_list{j}).algoritmo_precedente.f_sg;
        
        % Spirometro
        f_spiro(i,j) = subjs_in(i).data.(speed_list{j}).bpflt.f_spiro;
        f_spiro_bpm(i,j) = subjs_in(i).data.(speed_list{j}).bpflt.f_spiro_bpm;
        
        % Errors
        % Spiro vs Segnali pca
        e_spiro_pca(i,j) = abs(f_spiro(i,j) - f_pca(i,j));
        e_spiro_pca_bpm(i,j) = abs(f_spiro_bpm(i,j) - f_pca_bpm(i,j));
        e_spiro_oldanalysis(i,j) = abs(f_spiro(i,j) - f_sg_old(i,j));
        
    end % end for j
end  % end for i

%% TODO

e_spiro_pca_overspeed_ave = mean(e_spiro_pca,1);
e_spiro_pca_bpm_overspeed_ave = mean(e_spiro_pca_bpm,1);
e_spiro_pca_overspeed_sd = std(e_spiro_pca,0,1);
e_spiro_pca_bpm_overspeed_sd = std(e_spiro_pca_bpm,0,1);

% compute celss
e_spiro_pca_overspeed_cell = num2cell(e_spiro_pca_overspeed_ave);
e_spiro_pca_bpm_overspeed_cell = num2cell(e_spiro_pca_bpm_overspeed_ave);

% compute tables
var_names_1 = {'Speed: 0 km/h [Hz]', 'Speed: 1.6 km/h [Hz]', 'Speed: 3 km/h [Hz]', 'Speed: 5 km/h [Hz]', 'Speed: 6.6 km/h [Hz]', 'Speed: 8 km/h [Hz]'};
var_names_2 = {'Speed: 0 km/h [bpm]', 'Speed: 1.6 km/h [bpm]', 'Speed: 3 km/h [bpm]', 'Speed: 5 km/h [bpm]', 'Speed: 6.6 km/h [bpm]', 'Speed: 8 km/h [bpm]'};
e_spiro_pca_overspeed_tbl = cell2table(e_spiro_pca_overspeed_cell,'VariableNames',var_names_1);
e_spiro_pca_bpm_overspeed_tbl = cell2table(e_spiro_pca_bpm_overspeed_cell,'VariableNames',var_names_2);
%% Save output
out.DeltaF.e_spiro_pca_overspeed_ave = e_spiro_pca_overspeed_ave;
out.DeltaF.e_spiro_pca_bpm_overspeed_ave = e_spiro_pca_bpm_overspeed_ave;
out.DeltaF.e_spiro_pca_overspeed_sd = e_spiro_pca_overspeed_sd;
out.DeltaF.e_spiro_pca_bpm_overspeed_sd = e_spiro_pca_bpm_overspeed_sd;
out.MAE.e_spiro_oldanalysis = e_spiro_oldanalysis;
out.MAE.e_spiro_pca = e_spiro_pca;
end