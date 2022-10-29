%% Luigi Raiano, v1, 19-03-2020
% For further informaiton please refer to http://ufldl.stanford.edu/tutorial/unsupervised/PCAWhitening/
%
% Input
% x:            input matrix containing data of which comput PCA.
%
% Output:
% U:            matrix of the coefficients.
%                   - If size(x) are n_samples X n_sensors --> size(U): n_sensors X n_components
%                   - If size(x) are n_sensors X n_samples --> size(U): n_components X n_sensors
% x_rot:        Principal components evaluated (x with zero mean and rotated in
%               the U basis)
% explained:    explained variance of the input signal by each component.
% x_white:      centered and whitened version of the input signals.
% 
% Both x_rot and x_white have the same dimensions of the input signals x
%
%%
function [U,x_rot,explained,x_white] = compute_pca_v1(x)

% The following code need data input as: n_sensrs X n_samples. Thus, if the
% data in input are as a tall matrix, transpose. In case of data will be
% transposed, also the outpu variables will be transposed.
transposed = false;
if(size(x,1) > size(x,2))
    x = x';
    transposed = true;
end

% 1 - remove the mean
[x_nomean, mean_x] = remmean(x); % include FastICA_25 folder to use this function

% 2 - Compute the covariance matrix (Sigma)
n_signals = size(x_nomean,1);
Sigma = (x_nomean*x_nomean')./n_signals;

% 3 - Compute eigenvectors of Covariance matrix (\Sigma)
[U,S,V] = svd(Sigma); % performs decomposition so that Sigma = U*S*V
% being the matrix Sigma simmetric,. U and V are the same and they both
% contain the eogenvectors for matrix Sigma. S is the vecotors of the
% eigenvalues.

% Note: U is a matrix such that: n_components X n_sensors. If the input
% data are a tall matrix, this function will be: n_sensors X n_components

% Forward transformation
x_rot = U' * x_nomean;
% Inverse transformation
x_rec = U*x_rot + repmat(mean_x,1,size(x_rot,2));

epsilon = 1e-5;

% x_white = diag(1./sqrt(diag(S) + epsilon)) * U' * x; x_nomean
x_rot_white = diag(1./sqrt(diag(S) + epsilon)) * U' * x_nomean;
x_white = diag(1./sqrt(diag(S) + epsilon)) * x_nomean;

eigvals = nonzeros(S);
variance = abs(eigvals)./sum(eigvals);
explained = variance.*100;

if(transposed)
    U = U';
    x_rot = x_rot';
    x_white = x_white';
end
end