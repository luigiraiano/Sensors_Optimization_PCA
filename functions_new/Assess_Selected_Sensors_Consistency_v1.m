function [f_err_cell, f_err_bpm_cell, sel_senrs_id_cell] = Assess_Selected_Sensors_Consistency_v1(subjs_in)
subjs_out = [];
subjs_out = subjs_in;

f_err_cell = [];
f_err_bpm_cell = [];
sel_senrs_id_cell = [];

for i=1:length(subjs_out) % loop su N_subjs
    
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    
    for j = 1:length(speed_list) % loop su N_speeds
        subj_data = [];
        subj_data = subjs_out(i).data.(speed_list{j}).sensors_reduced;
        
        % Spectrum of selected sensors
        freq = []; P = []; f_sg = []; f_sg_bpm = [];
        srate = 250; % Hz
        piezo_sel = []; piezo_sel_id = [];
        piezo_sel = subj_data.segnale_textile;
        piezo_sel_id = subj_data.sensors_tokeep;
        
        for k = 1:size(piezo_sel,2)  % loop on selected sensors
            [~, freq(:,k), P(:,k), f_sg(k)] = Perform_PSD_v2(piezo_sel(:,k),srate);
        end % end for k
        f_sg_bpm = f_sg.*60;
        
        % Spiro RR estimation
        f_spiro = []; f_spiro_bpm = [];
        f_spiro = subjs_out(i).data.(speed_list{j}).bpflt.f_spiro;
        f_spiro_bpm = subjs_out(i).data.(speed_list{j}).bpflt.f_spiro_bpm;
        
        % Compute freqeuncy error
        f_err = []; f_err_bpm = [];
        for k = 1:size(piezo_sel,2) % loop on selected sensors
            f_err(k) = f_spiro - f_sg(k);
            f_err_bpm(k) = f_spiro_bpm - f_sg_bpm(k);
            
            f_err_cell{i,j}(k) = f_err(k);
            f_err_bpm_cell{i,j}(k) = f_err_bpm(k);
            
            sel_senrs_id_cell{i,j}(k) = piezo_sel_id(k);
        end % end for k
        
    end % end for j
    
end % end for i
end