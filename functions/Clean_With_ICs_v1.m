%% Luigi Raiano, v1, 12/09/2019
%
% INPUTs
% IC: indipendent component evaluated
% A: the estimated separating matrix W
% magnification: scalar factor used to increase ICA performance
%
% OUTPUTs
% data_rec: data reconstracted accorting to the inverse transformation
%%
function data_rec = Clean_With_ICs_v1(IC,A,selectedICs,magnification)
data_rec=A(:,selectedICs)*IC(selectedICs,:);

    data_rec=data_rec./magnification;
    data_rec = data_rec';
end