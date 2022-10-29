function [fitresult, gof] = createFit(A, B)
%CREATEFIT1(A,B)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : A
%      Y Output: B
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 27-Oct-2017 12:09:36


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( A, B );

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Lower = [-Inf 0];
opts.Upper = [Inf 0];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'B vs. A', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel A
ylabel B
grid on


