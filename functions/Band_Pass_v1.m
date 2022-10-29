% INPUTs
% data: n_channels X n_samples
% lowfq: low frequency [Hz]
% highfq: high frequency [Hz]
% ordfilt: order of the bandpass butterworth filter
% smpfq: sampling rate of the signal
%
% OUTPUTs
% filtdata: data band pass filtered
%%
function filtdata = Band_Pass_v1(data,lowfq,highfq,ordfilt,smpfq)
% Filtra i dati tra lowfq e highfq con ordine ordfilt e passo di campionamento smpfq
halfsmpfq=smpfq/2; 
filtdata=zeros(size(data));
[nraw,ncolumns]=size(data);
[A,B] = butter(ordfilt,[lowfq/halfsmpfq highfq/halfsmpfq]);
for k=1:nraw
    filtdata(k,:)=filtfilt(A,B,data(k,:));
end % end for
end % end function