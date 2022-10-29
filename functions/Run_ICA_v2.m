%% Luigi Raiano, v2, 21/10/2019
%
% Release notes:
% v2 implements ICA by means RobustICA algorithm (zarzoso et al 2010)
%
% INPUTs
% data: n_channels X n_sample double matrix.
%
% OUTPUTs
% IC: indipendent component evaluated
% H: the estimated separating matrix W
% iter: number of iteration run for evaluating ICs
% magnification: scalar factor used to increase ICA performance
%
% ICA Working principle
% IC = W*data --------> data = H*IC
%%
function [IC, H, iter, magnification] = Run_ICA_v2(data)
% Preprocessing for ICA

% Increase the amplitude of the signal to let ica perform better. Then
% remeber to divide by magnification the reconstructed signal
magnification = 10;
data = data.*magnification;

% make the data compatible for fast ica function (n_chans X n_samples)
% data = data';
arguments = {'deftype', 'regression', 'maxiter', 100}; % run ICA with whitnening and regression-based deflation. 
                                        % maxiter defines the maximum number of iteration when evaluating each compontn
[IC, H, iter, W] = robustica(data, arguments);

if(magnification ~= 1)
    warning(['magnification = ',num2str(magnification),'. Remember to scale the signal reconstructed!!!']);
end % end if

end % end function