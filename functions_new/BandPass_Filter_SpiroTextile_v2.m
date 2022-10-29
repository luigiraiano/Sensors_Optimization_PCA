function subjs_out = BandPass_Filter_SpiroTextile_v2(subjs_in,n_subjs,l_freq,h_freq,flt_ord,srate)
debug = 0;
subjs_out = subjs_in;
for i=1:n_subjs % loop su soggetti
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    n_speeds = []; n_speeds = length(speed_list);
    for j=1:n_speeds % loop su speeds
        spiro_filt = [];
        spiro_filt =  Band_Pass_v1(subjs_out(i).data.(speed_list{j}).raw_seg.segnale_spiro,l_freq,h_freq,flt_ord,srate);
        
        % [P_norm, freq, P, f_max] = Perform_PSD_v2(data,srate)
        [~, freq_spiroflt, P_spiroflt, f_max_spiro_flt] = Perform_PSD_v2(spiro_filt,srate);
        spiro = subjs_out(i).data.(speed_list{j}).raw_seg.segnale_spiro;
        [~, freq_spiro, P_spiro, f_max_spiro] = Perform_PSD_v2(spiro,250);
        
        % Debug
        if(debug)
            plot(freq_spiro,P_spiro); hold on;
            plot(freq_spiroflt,P_spiroflt); legend('raw','flt'); xlim([0,2.5]);
        end % if debug
        % Debug
        
        textile_flt = [];
        textile_flt =  Band_Pass_v1(subjs_out(i).data.(speed_list{j}).raw_seg.segnale_textile,l_freq,h_freq,flt_ord,srate);
        
        P_textileflt = []; freq_textileflt = [];
        P_textile = []; freq_textile = [];
        for k=1:size(textile_flt,2)
            [~,freq_textileflt(:,k),P_textileflt(:,k), f_max_textile_flt(k)] = Perform_PSD_v2(textile_flt(:,k),srate);
            [~,freq_textile(:,k),P_textile(:,k), f_max_textile(k)] = Perform_PSD_v2(subjs_out(i).data.(speed_list{j}).raw_seg.segnale_textile(:,k),srate);
        end % end for k
        Pave_textile = [];
        Pave_textile = mean(P_textileflt,2);
        [~, idx_max] = max(Pave_textile);
        
        f_max_Pave=freq_textileflt(idx_max,1);
        
        segnale_textile_ave = mean(textile_flt,2);
        P_textileave = [];
        [~, freq_textileave, P_textileave, f_max_textileave] = Perform_PSD_v2(segnale_textile_ave,srate);
        
        % Debug
        if(debug)
            subplot(1,2,1); plot(freq_textile,P_textile); xlim([0,2.5]); title('raw');
            subplot(1,2,2); plot(freq_textileflt,P_textileflt); xlim([0,2.5]); title('bp flt');
        end % debug
        % Debug
        
        % Compute Integral of the spiro
        spiro_int = [];
        tempo_spiro = subjs_out(i).data.(speed_list{j}).raw_seg.tempo_spiro;
        spiro_int = cumtrapz(tempo_spiro,spiro);
        spiro_int_flt = Band_Pass_v1(spiro_int,l_freq,h_freq,flt_ord,srate);
        
        % Save in subjects struct
        subjs_out(i).data.(speed_list{j}).bpflt.tempo_spiro = subjs_out(i).data.(speed_list{j}).raw_seg.tempo_spiro;
        subjs_out(i).data.(speed_list{j}).bpflt.segnale_spiro = spiro_filt;
        subjs_out(i).data.(speed_list{j}).bpflt.segnale_spiro_int = spiro_int_flt;

        
        subjs_out(i).data.(speed_list{j}).bpflt.tempo_textile = subjs_out(i).data.(speed_list{j}).raw_seg.tempo_spiro;
        subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile = textile_flt;
        
        subjs_out(i).data.(speed_list{j}).bpflt.f_spiro = f_max_spiro_flt; % [Hz]
        subjs_out(i).data.(speed_list{j}).bpflt.f_spiro_bpm = f_max_spiro_flt.*60; % [bpm]
        subjs_out(i).data.(speed_list{j}).bpflt.f_textile = f_max_textile_flt; % [Hz]
        subjs_out(i).data.(speed_list{j}).bpflt.f_textile_bpm = f_max_textile_flt.*60; % [bpm]
        subjs_out(i).data.(speed_list{j}).bpflt.f_Pave = f_max_Pave; % [Hz] calculated according prevoius works
        subjs_out(i).data.(speed_list{j}).bpflt.f_Pave_bpm = f_max_Pave.*60; % [bpm] calculated according prevoius works
%         subjs_out(i).data.(speed_list{j}).bpflt.f_textileave = f_max_textileave; % [Hz]
%         subjs_out(i).data.(speed_list{j}).bpflt.f_textileave_bpm = f_max_textileave.*60; % [bpm]
    end % end for j
    
end % end for i
end