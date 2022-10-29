%% Luigi Raiano, v1, 17-04-2020
% This function allows to run the function valutapsd implemented by
% Massaroni and Di Tocco.
%%
function subjs_out = Run_ValutaPSD_v1(subjs_in)
%%
debug = 0;
subjs_out = [];
subjs_out = subjs_in;

for i=1:length(subjs_in)% (subjects' length)
    speed_list = [];
    speed_list = fieldnames(subjs_out(i).data);
    
    for j=1:length(speed_list) % (speeds' length)
        textile_6_sensors = []; % segnale ritagliato e filtrato band-pass
        f_sg = []; % Hz
        f_sgbpm = []; % breath per minute
        textile_4_sensori = [];
        
        textile_6_sensors = subjs_out(i).data.(speed_list{j}).bpflt.segnale_textile;
        
        [f_sg, f_sgbpm, textile_4_sensori] = valutapsd(textile_6_sensors,0); % do not plot PSDs
        
        % Save variables
        subjs_out(i).data.(speed_list{j}).algoritmo_precedente.textile_4_sensori = textile_4_sensori;
        subjs_out(i).data.(speed_list{j}).algoritmo_precedente.f_sg = f_sg;
        subjs_out(i).data.(speed_list{j}).algoritmo_precedente.f_sgbpm = f_sgbpm;
        
    end % end for j (speeds' length)
    
end % end for i (subjects' length)


end