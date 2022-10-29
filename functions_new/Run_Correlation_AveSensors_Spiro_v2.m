%% Luigi Raiano, v2, 13-05-2020
% This function must be used within the
% main script main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v1.
%
% This function allows to perform a linear correlation between the average
% of the textile signals and spirometer in order to assess whether textile
% are colletaed with the reference in terms of capability to catch the
% brething.
%
% Input parameters
% 1- subjects struct, containing the data of all subjects. This has to be
%   computed within  main_ElabNoIMU_SensorsPlacementOptimizazion_PCA_v3
%   script
% 2- domain_analysis: this allows to select the domain in which the
%   correlation will be performed.
%   It can be either 'time' or 'frequency'
% 3- textitle_signal_flag: flag to choose which sensors to use among the
% original ones, the cleaned ones, the non-redundant ones and the best
% sensors selcted
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
%
% RELEASE NOTE v2
% It is possible to run the correlatoin also considering the best_sensors
% analysis
%%
function [subjs_out, corr_out] = Run_Correlation_AveSensors_Spiro_v2(subjs_in,domain_analysis,textitle_signal_flag,spiro_signal_integral)

time_domain_analysis_flag = true;
if(strcmp(domain_analysis,'time'))
    time_domain_analysis_flag = true;
elseif(strcmp(domain_analysis,'frequency'))
    time_domain_analysis_flag = false;
else
    error('Error typing. Choose time or frequency');
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

lfreq = 0.05; % Hz
hfreq = 2; % Hz
srate = 250; % Hz
ord_flt = 2;

for i=1:length(subjs_out)
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds
        textile_sig_all = [];
        textile_sig = [];
        spiro_sig = [];
        spiro = [];
        spiro = subjs_out(i).data.(speed_list{j}).bpflt.segnale_spiro;
        
        % choose whethere to use spiro integral of spiro raw
        if(use_spiro_integral)
            tempo_spiro = subjs_out(i).data.(speed_list{j}).bpflt.tempo_spiro;
            spiro_int = cumtrapz(tempo_spiro,spiro);
            spiro_sig = Band_Pass_v1(spiro_int,lfreq,hfreq,ord_flt,srate);
        else
            spiro_sig = spiro;
        end % end if
        
        % choose the textile signal to correlate
        if(strcmp(textitle_signal_flag,'original'))
            textile_sig_all = subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile;
        elseif(strcmp(textitle_signal_flag,'cleaned'))
            textile_sig_all = subjs_out(i).data.(speed_list{j}).clean_sensors.segnale_textile;
        elseif(strcmp(textitle_signal_flag,'non_redundant'))
            textile_sig_all = subjs_out(i).data.(speed_list{j}).sensors_reduced.segnale_textile;
        elseif(strcmp(textitle_signal_flag,'old_algorithm'))
            textile_sig_all = subjs_out(i).data.(speed_list{j}).algoritmo_precedente.textile_4_sensori;
        elseif(strcmp(textitle_signal_flag,'best_sensors'))
            textile_sig_all = subjs_out(i).data.(speed_list{j}).best_sensors.segnale_textile;
        end % end if
        
        textile_sig = sum(textile_sig_all,2);
        
        % choose whethere run correlation between variables expressed in
        % time domain or in frequency domain
        if(time_domain_analysis_flag)
            [R(i,j),p(i,j)] = corr(textile_sig,spiro_sig);
        else
            % Compute nPSD first
            srate = 250;
            [P_norm_textile, freq_pcsig, P_pcsig,~] = Perform_PSD_v2(textile_sig,srate);
            [P_norm_spiro, freq_spiro, P_spiro,~] = Perform_PSD_v2(spiro_sig,srate);
            
            [R(i,j),p(i,j)] = corr(P_norm_textile,P_norm_spiro);
        end % end if
       
        
        
        % Save data ouput
        new_field_name = ['pc',textitle_signal_flag,'_',spiro_signal_integral,'_',domain_analysis];
        subjs_out(i).data.(speed_list{j}).(new_field_name).R = R(i,j);
        subjs_out(i).data.(speed_list{j}).(new_field_name).p = p(i,j);
        
    end % end for j (speeds)
    
end % for i (subjects)

% Save output of the correlation
corr_out.R = R;
corr_out.p = p;

end