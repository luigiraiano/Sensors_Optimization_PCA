%% Luigi Raiano, v1, 12/10/2019
%
% INPUTs
% data: n_channels X n_sample double matrix.
%
% OUTPUTs
% IC: indipendent component evaluated
% A: the estimated separating matrix W
% WB: estimated separating matrix W
% magnification: scalar factor used to increase ICA performance
% IC = WB*data -> data = A*IC
%%
function [IC, A, WB, magnification] = Run_ICA_v1(data)
% Preprocessing for ICA
white=1;
% white=2; %la matrice W si ricava dalla PCA robusta massima verosimiglianza

subspace=''; % no reduction of the space
% subspace='lap'; % laplacian approximation
% subspace='eigenrnd'; % no reduction of the space

% Increase the amplitude of the signal to let ica perform better. Then
% remeber to divide by magnification the reconstructed signal
magnification = 50;
data = data.*magnification;

% make the data compatible for fast ica function (n_chans X n_samples)
% data = data';


% run PCA to choose the minimum number of component. If subspace='', any
% optimization is implemented and all component are considered.
[Weigenrnd,d]=prepro(data,white,subspace);  

if(isstruct(Weigenrnd))
     W=Weigenrnd(1).mat;
else
    W = Weigenrnd;
end % end if

% W=Weigenrnd(1).mat; %The number in brackets indicates the number of components chosen from the list

xw=W*data;

if(size(W,1) == size(W,2))
    Winv=inv(W);
else
   Winv=pinv(W); 
end % end if
% Run ICA
[IC, A, WB] =fastica(data,'g', 'tanh','whiteSig',xw,'whiteMat',W,'dewhiteMat',Winv,'displayMode', 'off'); % Doing ICA


if(magnification ~= 1)
    warning(['magnification = ',num2str(magnification),'. Remember to scale the signal reconstructed!!!']);
end % end if

end % end function