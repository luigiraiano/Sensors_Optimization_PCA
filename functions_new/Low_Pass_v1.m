% INPUTs
% data: n_channels X n_samples
% cutoff: cut off frequency [Hz]
% ordfilt: order of the bandpass butterworth filter
% smpfq: sampling rate of the signal
%
% OUTPUTs
% filtdata: low pass filtered data
%%
function filtdata = Low_Pass_v1(data,cutoff,ordfilt,smpfq)
% Filtra i dati tra lowfq e highfq con ordine ordfilt e passo di campionamento smpfq
halfsmpfq=smpfq/2; 
filtdata=zeros(size(data));
[nraw,ncolumns]=size(data);
[A,B] = butter(ordfilt,cutoff/halfsmpfq);
for k=1:nraw
    filtdata(k,:)=filtfilt(A,B,data(k,:));
end % end for
end % end function