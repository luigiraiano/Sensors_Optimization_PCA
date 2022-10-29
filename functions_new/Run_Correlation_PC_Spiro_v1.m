%% Luigi Raiano, v1, 05-04-2020
% This function must be used within the
% main script main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v1.
%
% This function allows to perform a linear correlation between principal
% components and spirometer in order to assess whether the principal
% component outcome is capable to describe repiratory signals.
%
% Input parameters
% 1- subjects struct, containing the data of all subjects. This has to be
%   computed within  main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v3
%   script
% 2- domain_analysis: this allows to select the domain in which the
%   correlation will be performed.
%   It can be either 'time' or 'frequency'
% 3- pc_selected: flag which describes the princupal components used to
% perform the correlation.
% This varaible can assume the following values:
%   - 'first': only the first PC will be used to run the linear correlation
%   - 'all': the correlation will be performed between the \overline{p}
%   components selected to explain the \alpha% of the signal
% 4- spiro_signal_integral: flag variable to use the integral of the
% recorded spiro signal or its integral. This fal can assume the following
% values:
%   - 'spiro_raw': to use the signal recorded by the spirometer
%   - 'spiro_int': to use the integral of signal recorded by the spirometer
%
% Output parameters
% 1- subjs_out: uograde of the input struct subj_in
% 2- corr_out is a struct containing trhee fields:
%   - pearson's corfficient of each correlation between nPSD(PC1))
%   and nPSD((spiro))
%   signal. It is a N_subjects X N_speeds matrix
%
%   - p value of the correlations. It is a N_subjects X N_speeds matrix
%
%   - variance explained by the PC1 used to perform the correlation. It is
%   a N_subjects X N_speeds matrix
%%
function [subjs_out, corr_out] = Run_Correlation_PC_Spiro_v1(subjs_in,domain_analysis,pc_selected,spiro_signal_integral)

time_domain_analysis_flag = true;
if(strcmp(domain_analysis,'time'))
    time_domain_analysis_flag = true;
elseif(strcmp(domain_analysis,'frequency'))
    time_domain_analysis_flag = false;
else
    error('Error typing. Choose time or frequency');
end

use_first_pc = true;
if(strcmp(pc_selected,'first'))
    use_first_pc = true;
elseif(strcmp(pc_selected,'all'))
    use_first_pc = false;
else
    error('Error typing. Choose first or all');
end

use_spiro_integral = true;
if(strcmp(spiro_signal_integral,'spiro_int'))
    use_spiro_integral = true;
elseif(strcmp(spiro_signal_integral,'spiro_raw'))
    use_spiro_integral = false;
else
    error('Error typing. Choose spiro_int or spiro_raw');
end

subjs_out = subjs_in;
corr_out = [];

for i=1:length(subjs_out)
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds
        pc_sig = [];
        spiro_sig = [];
        spiro = [];
        spiro = subjs_out(i).data.(speed_list{j}).bpflt.segnale_spiro;
        
        % choose whethere to use spiro integral of spiro raw
        if(use_spiro_integral)
            tempo_spiro = subjs_out(i).data.(speed_list{j}).bpflt.tempo_spiro;
            spiro_sig = cumtrapz(tempo_spiro,spiro);
        else
            spiro_sig = spiro;
        end % end if
        
        % choose whethere to use first or \overline{p} componenets
        if(use_first_pc)
            pc_sig = subjs_out(i).data.(speed_list{j}).PCA.textile_rot(:,1);
            idx_pc = 1;
        else
            idx_reduced = subjs_out(i).data.(speed_list{j}).PCA.idx_explained;
            idx_pc = idx_reduced;
            pc_sig_tmp = subjs_out(i).data.(speed_list{j}).PCA.textile_rot(:,1:idx_reduced);
            pc_sig = mean(pc_sig_tmp,2);
        end % end if
        
        % choose whethere run correlation between variables expressed in
        % time domain or in frequency domain
        if(time_domain_analysis_flag)
            [R(i,j),p(i,j)] = corr(pc_sig,spiro_sig);
        else
            % Compute nPSD first
            srate = 250;
            [P_norm_pcsig, freq_pcsig, P_pcsig] = Perform_PSD_v1(pc_sig,srate);
            [P_norm_spiro, freq_spiro, P_spiro] = Perform_PSD_v1(spiro_sig,srate);
            
            [R(i,j),p(i,j)] = corr(P_norm_pcsig,P_norm_spiro);
        end % end if
        
        var_expl(i,j) = sum(subjs_out(i).data.(speed_list{j}).PCA.variance_explained(1:idx_pc));
        
        subjs_out(i).data.(speed_list{j}).pc_spiro_corr.R = R(i,j);
        subjs_out(i).data.(speed_list{j}).pc_spiro_corr.p = p(i,j);
        subjs_out(i).data.(speed_list{j}).pc_spiro_corr.variance_expl_pc1 = var_expl(i,j);
        
    end % end for j (speeds)
    
end % for i (subjects)

% Save output of the correlation
corr_out.R = R;
corr_out.p = p;
corr_out.var_explained = var_expl;

end