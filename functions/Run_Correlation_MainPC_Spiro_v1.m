%% Luigi Raiano, v1, 24-03-2020
% This function must be used within the
% main script main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v1.
%
% corr_out is a struct containing trhee fields:
%   1- pearson's corfficient of each correlation between PC1 and spiro
%   signal. It is a N_subjects X N_speeds matrix
%
%   2- p value of the correlations. It is a N_subjects X N_speeds matrix
%
%   3- variance explained by the PC1 used to perform the correlation. It is
%   a N_subjects X N_speeds matrix
%
%%
function [subjs_out, corr_out] = Run_Correlation_MainPC_Spiro_v1(subjs_in)
subjs_out = subjs_in;
corr_out = [];

for i=1:length(subjs_out)
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds
        first_pc = [];
        first_pc = subjs_out(i).data.(speed_list{j}).PCA.textile_rot(:,1);
        
        spiro = [];
        spiro = subjs_out(i).data.(speed_list{j}).bpflt.segnale_spiro;
        
        [R(i,j),p(i,j)] = corr(smooth(first_pc),spiro);
        var_expl(i,j) = subjs_out(i).data.(speed_list{j}).PCA.variance_explained(1);
        
        subjs_out(i).data.(speed_list{j}).pc1_spiro_corr.R = R(i,j);
        subjs_out(i).data.(speed_list{j}).pc1_spiro_corr.p = p(i,j);
        subjs_out(i).data.(speed_list{j}).pc1_spiro_corr.variance_expl_pc1 = var_expl(i,j);
        
    end % end for j
    
end % end for i

% Save output of the correlation
corr_out.R = R;
corr_out.p = p;
corr_out.var_expl_pc1 = var_expl;

end % end function