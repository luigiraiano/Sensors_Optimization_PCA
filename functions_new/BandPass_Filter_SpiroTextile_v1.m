function subjs_out = BandPass_Filter_SpiroTextile_v1(subjs_in,n_subjs,l_freq,h_freq,flt_ord,srate)
debug = 0;
subjs_out = subjs_in;
for i=1:n_subjs % loop su soggetti
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds % loop su speeds
        spiro_filt = [];
        spiro_filt =  Band_Pass_v1(subjs_out(i).data.(speed_list{j}).raw_seg.segnale_spiro,l_freq,h_freq,flt_ord,srate);
        
        % Debug
        if(debug)
            [~, freq_spiroflt, P_spiroflt, ~] = Perform_PSD_v1(spiro_filt,srate);
            spiro = subjs_out(i).data.(speed_list{j}).raw_seg.segnale_spiro;
            [~, freq_spiro, P_spiro, ~] = Perform_PSD_v1(spiro,250);
            plot(freq_spiro,P_spiro); hold on;
            plot(freq_spiroflt,P_spiroflt); legend('raw','flt'); xlim([0,2.5]);
        end % if debug
        % Debug
        
        textile_flt = [];
        textile_flt =  Band_Pass_v1(subjs_out(i).data.(speed_list{j}).raw_seg.segnale_textile,l_freq,h_freq,flt_ord,srate);
        
        % Debug
        if(debug)
            P_textileflt = []; freq_textileflt = [];
            P_textile = []; freq_textile = [];
            for k=1:size(textile_flt,2)
                [~,freq_textileflt(:,k),P_textileflt(:,k)] = Perform_PSD_v1(textile_flt(:,k),srate);
                [~,freq_textile(:,k),P_textile(:,k)] = Perform_PSD_v1(subjs_out(i).data.(speed_list{j}).raw_seg.segnale_textile(:,k),srate);
            end % end for k
            subplot(1,2,1); plot(freq_textile,P_textile); xlim([0,2.5]); title('raw');
            subplot(1,2,2); plot(freq_textileflt,P_textileflt); xlim([0,2.5]); title('bp flt');
        end % debug
        % Debug
        
        % Save in subjects struct
        subjs_out(i).data.(speed_list{j}).bpflt.tempo_spiro = subjs_out(i).data.(speed_list{j}).raw_seg.tempo_spiro;
        subjs_out(i).data.(speed_list{j}).bpflt.segnale_spiro = spiro_filt;
        
        subjs_out(i).data.(speed_list{j}).bpflt.tempo_textile = subjs_out(i).data.(speed_list{j}).raw_seg.tempo_spiro;
        subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile = textile_flt;
    end % end for j
    
end % end for i
end