%% Luigi Raiano, v1, 19-03-2020
% Run PCA on all signals (textile). This function must be used within the
% main script main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v1.
%
% explained_perc_thres: is expressed in [%], thus it ranges from 0-100
%
%%
function subjs_out = Run_PCA_v1(subjs_in,explained_perc_thres)
debug = 0;
subjs_out = subjs_in;

n_subjs = length(subjs_in);
for i=1:n_subjs
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds
        x = [];
        x = subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile; % n_samples X n_sensors
        
        % Use pca() to compute PCA. It is embedded in Machine Learning
        % Toolbox. If you want compute the PCA manually, refers to the
        % funcion compute_pca_v1(). The latter allows to compute also the
        % whithened version of the input signal.
        
        % 1 - Compute PCA
        % x_rot = x_in*U; --> U_ij: wieght of the sensor i on the component j
        %                 --> x_rot: input signal centered and rotated in
        %                            the new basis U. For this reason, this is the
        %                            matric of the PCs
        [U,x_rot,variance,tsquared,explained,mu] = pca(x,'Centered',true,'Algorithm','svd');
        % Inverse transformation
        x_rec = x_rot*U' + repmat(mu,size(x_rot,1),1); % not needed for the purpose of the article sensors placecement and optimizaion.
        
        % 2 - PCs to explain the explained_perc_thres % of the signal
        % contained in x
        sum_explained = 0;
        idx_explained = 0;
        while(sum_explained <= explained_perc_thres)
            idx_explained = idx_explained + 1;
            sum_explained = sum_explained + explained(idx_explained);
        end % end while
        U_reduced = U(:,1:idx_explained); % N_sensors X N_PCs
        x_rot_reduced = x_rot(:,1:idx_explained);
        
        % PSD of the pc to explain explained_perc_thres of the input signal
        freq = []; P = [];
        srate = 250; % Hz
        for k = 1:size(x_rot_reduced,2)
            [~, freq(:,k), P(:,k), ~] = Perform_PSD_v2(x_rot_reduced(:,k),srate);
        end
        % Find the max peak in the ave PSD
        P_ave = mean(P,2);
        [~, idx_max] = max(P_ave);
        f_max_pca=freq(idx_max); % frequency of the maximal peak
        f_max_bpm_pca = f_max_pca.*60; % breath per minute;
            
        
        % Save PCA related results.
        subjs_out(i).data.(speed_list{j}).PCA.U = U;
        subjs_out(i).data.(speed_list{j}).PCA.textile_rot = x_rot;
        subjs_out(i).data.(speed_list{j}).PCA.textile_rot_reduced = x_rot_reduced;
        subjs_out(i).data.(speed_list{j}).PCA.textile_mean = mu;
        subjs_out(i).data.(speed_list{j}).PCA.variance_explained = explained;
        subjs_out(i).data.(speed_list{j}).PCA.idx_explained = idx_explained;
        subjs_out(i).data.(speed_list{j}).PCA.U_reduced = U_reduced;
        subjs_out(i).data.(speed_list{j}).PCA.n_comps_kept = size(U_reduced,2);
        subjs_out(i).data.(speed_list{j}).PCA.f_pca = f_max_pca;
        subjs_out(i).data.(speed_list{j}).PCA.fbpm_pca = f_max_bpm_pca;
        
    end % end for j
    
end % end for i

end % end function