%% Luigi Raiano, v1, 21/09/2019
%
% Release notes:
% v2 data reconstructed after having run ICA by means fastICA algorithm (A. Hyvarinen et al 1997)
%
% INPUTs
% IC: indipendent component evaluated
% H: the estimated separating matrix W
% magnification: scalar factor used to increase ICA performance
%
% OUTPUTs
% data_rec: data reconstracted accorting to the inverse transformation
%%
function data_rec = Clean_With_ICs_v3(IC,H,selectedICs,magnification)
data_rec=H(:,selectedICs)*IC(selectedICs,:);

    data_rec=data_rec./magnification;
    data_rec = data_rec';
end