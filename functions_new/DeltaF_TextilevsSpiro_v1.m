%% Luigi Raiano, v1, 20-05-2020
%%
function out = DeltaF_TextilevsSpiro_v1(subjs_in)

out = [];
% frequenza max psd per piezo e flow e determina la differenza (calcolata
% come frequenza massima della PSD media dei sensori, n_sensors >1 )

% Segnali non ridondanti
f_nonred = []; f_nonred_bpm = [];

% Metodo articolo precedente
f_ref = []; f_ref_bpm = [];

% Best Sensors
f_best = []; f_best_bpm = [];

% Spirometro
f_spiro = []; f_spiro_bpm = [];

% Errori
% spiro - non red
e_spiro_nonred = []; e_spiro_nonred_bpm = [];
% spiro - ref
e_spiro_ref = []; e_spiro_ref_bpm = [];
% spiro - best
e_spiro_best = []; e_spiro_best_bpm = [];

for i=1:length(subjs_in) % loop su soggetti
    speed_list = fieldnames(subjs_in(i).data);
    
    for j=1:length(speed_list) % loop su speed
        
        % Segnali non ridondanti
        f_nonred(i,j) = subjs_in(i).data.(speed_list{j}).sensors_reduced.f_nonred;
        f_nonred_bpm(i,j) = subjs_in(i).data.(speed_list{j}).sensors_reduced.fbpm_nonred;
        
        % Metodo articolo precedente
        f_ref(i,j) = subjs_in(i).data.(speed_list{j}).algoritmo_precedente.f_sg;
        f_ref_bpm(i,j) = subjs_in(i).data.(speed_list{j}).algoritmo_precedente.f_sgbpm;
        
        % Best Sensors
        f_best(i,j) = subjs_in(i).data.(speed_list{j}).best_sensors.f_max;
        f_best_bpm(i,j) = subjs_in(i).data.(speed_list{j}).best_sensors.f_max_bpm;
        
        % Spirometro
        f_spiro(i,j) = subjs_in(i).data.(speed_list{j}).bpflt.f_spiro;
        f_spiro_bpm(i,j) = subjs_in(i).data.(speed_list{j}).bpflt.f_spiro_bpm;
        
        % Errors
        % Spiro vs Segnali non ridondanti
        e_spiro_nonred(i,j) = f_spiro(i,j) - f_nonred(i,j);
        e_spiro_nonred_bpm(i,j) = f_spiro_bpm(i,j) - f_nonred_bpm(i,j);
        
        % Spiro vs Segnali articolo prec
        e_spiro_ref(i,j) = f_spiro(i,j) - f_ref(i,j);
        e_spiro_ref_bpm(i,j) = f_spiro_bpm(i,j) - f_ref_bpm(i,j);
        
        % Spiro vs Segnali best
        e_spiro_best(i,j) = f_spiro(i,j) - f_best(i,j);
        e_spiro_best_bpm(i,j) = f_spiro_bpm(i,j) - f_best_bpm(i,j);
        
    end % end for j
end  % end for i

%% TODO

e_spiro_nonred_overspeed = mean(e_spiro_nonred,1);
e_spiro_nonred_bpm_overspeed = mean(e_spiro_nonred_bpm,1);
e_spiro_nonred_bpm_overspeed_sd = std(e_spiro_nonred_bpm,0,1);

e_spiro_ref_overspeed = mean(e_spiro_ref,1);
e_spiro_ref_bpm_overspeed = mean(e_spiro_ref_bpm,1);
e_spiro_ref_bpm_overspeed_sd = std(e_spiro_ref_bpm,0,1);

e_spiro_best_overspeed = mean(e_spiro_best,1);
e_spiro_best_bpm_overspeed = mean(e_spiro_best_bpm,1);
e_spiro_best_bpm_overspeed_sd = std(e_spiro_best_bpm,0,1);

% compute celss
e_spiro_nonred_overspeed_cell = num2cell(e_spiro_nonred_overspeed);
e_spiro_nonred_bpm_overspeed_cell = num2cell(e_spiro_nonred_bpm_overspeed);

e_spiro_ref_overspeed_cell = num2cell(e_spiro_ref_overspeed);
e_spiro_ref_bpm_overspeed_cell = num2cell(e_spiro_ref_bpm_overspeed);

e_spiro_best_overspeed_cell = num2cell(e_spiro_best_overspeed);
e_spiro_best_bpm_overspeed_cell = num2cell(e_spiro_best_bpm_overspeed);

% compute tables
var_names_1 = {'Speed: 0 km/h [Hz]', 'Speed: 1.6 km/h [Hz]', 'Speed: 3 km/h [Hz]', 'Speed: 5 km/h [Hz]', 'Speed: 6.6 km/h [Hz]', 'Speed: 8 km/h [Hz]'};
var_names_2 = {'Speed: 0 km/h [bpm]', 'Speed: 1.6 km/h [bpm]', 'Speed: 3 km/h [bpm]', 'Speed: 5 km/h [bpm]', 'Speed: 6.6 km/h [bpm]', 'Speed: 8 km/h [bpm]'};
e_spiro_nonred_overspeed_tbl = cell2table(e_spiro_nonred_overspeed_cell,'VariableNames',var_names_1);
e_spiro_nonred_bpm_overspeed_tbl = cell2table(e_spiro_nonred_bpm_overspeed_cell,'VariableNames',var_names_2);

e_spiro_ref_overspeed_tbl = cell2table(e_spiro_ref_overspeed_cell,'VariableNames',var_names_1);
e_spiro_ref_bpm_overspeed_tbl = cell2table(e_spiro_ref_bpm_overspeed_cell,'VariableNames',var_names_2);

e_spiro_best_overspeed_tbl = cell2table(e_spiro_best_overspeed_cell,'VariableNames',var_names_1);
e_spiro_best_bpm_overspeed_tbl = cell2table(e_spiro_best_bpm_overspeed_cell,'VariableNames',var_names_2);
%% Save output
out.DeltaF.e_spiro_nonred_overspeed = e_spiro_nonred_overspeed;
out.DeltaF.e_spiro_nonred_bpm_overspeed = e_spiro_nonred_bpm_overspeed;
out.DeltaF.e_spiro_nonred_bpm_overspeed_sd = e_spiro_nonred_bpm_overspeed_sd;

out.DeltaF.e_spiro_ref_overspeed = e_spiro_ref_overspeed;
out.DeltaF.e_spiro_ref_bpm_overspeed = e_spiro_ref_bpm_overspeed;
out.DeltaF.e_spiro_ref_bpm_overspeed_sd = e_spiro_ref_bpm_overspeed_sd;

out.DeltaF.e_spiro_best_overspeed = e_spiro_best_overspeed;
out.DeltaF.e_spiro_best_bpm_overspeed = e_spiro_best_bpm_overspeed;
out.DeltaF.e_spiro_best_bpm_overspeed_sd = e_spiro_best_bpm_overspeed_sd;
end