function [W,d,variance,nComponents]=prepro(x,white,subspace)
%verificare se x devono essere normalizzati rispetto al ROBUST PREWHITENIONG (da FARE!!!!)
%questa funzione attua diverse procedure di prewhitening e riduzione dei dati restituendo in output 
%la matrice W di whitening in base all'opzione white scelta e all'opzione subspace scelta
%white=0 : la matrice W e' la matrice identita'
%white=1 : la matrice W si ricava dalla PCA standard
%white=2 : la matrice W si ricava dalla PCA robusta massima verosimiglianza (svd su Rxx)
%white=3 : la matrice W si ricava dalla PCA robusta con le m-stime (svd su Rxx)
%subspace=''            :No reduction
%subspace='aic'         :Akaike Information Criterion
%subspace='mdl'         :Minimum Description Length
%subspace='bic'         :Bayesian Information Criterion
%subspace='rankdet'     :Rank Detection Criterion
%subspace='lap'         :Laplace approximation
%subspace='eigenrnd'    :Eigen Round approximation Procedure
%subspace='numICs'      :Numero delle IC da stimare

[r,c]=size(x);

if white==0
  disp('Prewhitening is not required.') 
  W=eye(r,r);
end 

if(white==1 | white==2)
  [x, meanxml] = remmean(x);
  Rxx=x*x'/c;
  [u,d,v]=svd(Rxx+eye(r));
  d=diag(d)-1;
  r=max(find(d>1e-9)); 
  d=d(1:r);

  if(white==1)
    % Standard PREWHITENING
    disp('Standard Prewhitening ...') 
  end
  if(white==2 & ~isempty(subspace))
    % Robust ML PREWHITENING
    disp('Robust ML Prewhitening ...') 
  end
   
  if(isempty(subspace))
      disp('... No Reduction') 
      W=(u(:,1:r)*diag(real(sqrt(1./d))))'; 
  end
  
  if(strcmp(subspace,'numICs')==1)
      disp('... user chosen ICs estimation') 
      numComp=0;
      numComp=input('How many components do you want? :');
      W=(u(:,1:numComp)*diag(real(sqrt(1./d(1:numComp)))))'; 
      fprintf('\n Variance explained by the first %d Principal Components selected by the user... ',numComp);
      lambdaTot=sum(d);
      variance=sum( d(1:numComp) ) / lambdaTot
  end
  
  if(strcmp(subspace,'aic')==1)
      disp('... AIC Reduction') 
      [valAIC,k]=AIC(d,c);
      %k=round(k)
      [W,varNEstML]=estimateW(d,k,u,white);
      disp('Variance explained by Principal Components selected AIC... ')
      lambdaTot=sum(d);
      variance=sum( d(1:k) ) / lambdaTot
  end
  
  if(strcmp(subspace,'mdl')==1)
      disp('... MDL Reduction') 
      [valMDL,k]=MDL(d,c);
      [W,varNEstML]=estimateW(d,k,u,white);
       disp('Variance explained by Principal Components selected MDL... ')
      lambdaTot=sum(d);
      variance=sum( d(1:k) ) / lambdaTot
  end
  
  if(strcmp(subspace,'bic')==1)
      disp('... BIC Reduction') 
      [k,valBIC]=bic_pca([],d,r,c);
      [W,varNEstML]=estimateW(d,k,u,white);
       disp('Variance explained by Principal Components selected BIC... ')
      lambdaTot=sum(d);
      variance=sum( d(1:k) ) / lambdaTot
  end
  
  if(strcmp(subspace,'rankdet')==1)
      disp('... EIGEN RANK Reduction') 
      [gap, minGap, k]=EigenRank(d);
      [W,varNEstML]=estimateW(d,k,u,white);
       disp('Variance explained by Principal Components selected EIGEN RANK... ')
      lambdaTot=sum(d);
      variance=sum( d(1:k) ) / lambdaTot
  end
  
  if(strcmp(subspace,'lap')==1)
      disp('... LAPLACE Reduction') 
      [k,p] = laplace_pca([], d, r, c);
      [W,varNEstML]=estimateW(d,k,u,white);
       disp('Variance explained by Principal Components selected LAPLACE... ')
      lambdaTot=sum(d);
      variance=sum( d(1:k) ) / lambdaTot
  end
  
  if(strcmp(subspace,'eigenrnd')==1)
      disp('... EIGEN ROUND Reduction') 
      [nComponents]=eigenround(d)
      [rg,cl]=size(nComponents);
      disp('Variance explained by Principal Components selected EIGEN ROUND... ')
      lambdaTot=sum(d);
      for(i=1:rg)
         k=nComponents(i,1);
         [Wtemp,varNEstMLTemp]=estimateW(d,k,u,white);
         W(i).mat=Wtemp;
         varNEstML(i)=varNEstMLTemp;
         %disp('Variance explained by Principal Components selected ... ')
         %lambdaTot=sum(d);
         W(i).variance=sum( d(1:k) ) / lambdaTot;
      end
      for(i=1:rg)
          W(i).variance
      end
          
      disp('Note that: W is a structured array !!! ') 
  end
  disp('Done.')
end 
    
  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Auxiliary Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [W,varNEstML]=estimateW(d,k,u,white)   
if(white==1)
    W=(u(:,1:k)*diag(real(sqrt(1./d(1:k)))))'; 
    varNEstML=0;
end
if(white==2)
    disp('Removing ML estimated variance noise......')
    varNEstML=mean(d((k+1):length(d)));
    drobML=d-varNEstML;
    W=(u(:,1:k)*diag(real(sqrt(1./drobML(1:k)))))' ;   
end
    
  
function [newVectors, meanValue] = remmean(vectors);
%REMMEAN - remove the mean from vectors
%
% [newVectors, meanValue] = remmean(vectors);
%
% Removes the mean of row vectors.
% Returns the new vectors and the mean.
%
% This function is needed by FASTICA and FASTICAG

% 24.8.1998
% Hugo Gävert

newVectors = zeros (size (vectors));
meanValue = mean (vectors')';
newVectors = vectors - meanValue * ones (1,size (vectors, 2));

function [AIC,posAIC]=AIC(eigenvalues,c)
p=length(eigenvalues);
for (k=0:p-1)
    aTemp=1;
    bTemp=0;
    for (i=k+1:p)
        aTemp=aTemp*eigenvalues(i)^(1/(p-k));
    end
    for (i=k+1:p)
        bTemp=bTemp+eigenvalues(i);
    end
    bTemp=(1/(p-k))*bTemp;
    cTemp=(aTemp/bTemp)^((p-k)*c);
    if(cTemp==0)
       AIC(k+1)=inf;
    else
        AIC(k+1)=-2*log(cTemp)+2*k*((2*p)-k);
    end
end
[posAIC(2) posAIC(1)]=min(AIC);
posAIC(1)=posAIC(1)-1;

function [MDL,posMDL]=MDL(eigenvalues,c)
p=length(eigenvalues);
for (k=0:p-1)
    aTemp=1;
    bTemp=0;
    for (i=k+1:p)
        aTemp=aTemp*eigenvalues(i)^(1/(p-k));
    end
    for (i=k+1:p)
        bTemp=bTemp+eigenvalues(i);
    end
    bTemp=(1/(p-k))*bTemp;
    cTemp=(aTemp/bTemp)^((p-k)*c);
     if(cTemp==0)
       MDL(k+1)=inf;
    else
        MDL(k+1)=-log(cTemp)+0.5*k*((2*p)-k)*log(c);
    end
end
[posMDL(2) posMDL(1)]=min(MDL);
posMDL(1)=posMDL(1)-1;


function [k,p] = bic_pca(data, e, d, n)
% BIC_PCA   Estimate latent dimensionality by BIC approximation.
%
% BIC_PCA([],e,d,n) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues e, original dimensionality d, and size n.
% BIC_PCA(data) computes (e,d,n) from the matrix data 
% (data points are rows).
% [k,p] = BIC_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  k is the argmax of p.

if ~isempty(data)
  [n,d] = size(data);
  m = mean(data);
  data0 = data - repmat(m, n, 1);
  e = svd(data0,0).^2;
end
e = e(:);
% break off the eigenvalues which are identically zero
i = find(e < eps);
e(i) = [];

kmax = min([d-1 n-2]);
%kmax = min([kmax n/2]);
ks = 1:kmax;
for i = 1:length(ks)
  k = ks(i);
  e1 = e(1:k);
  e2 = e((k+1):length(e));
  v = sum(e2)/(d-k);
  % we can equivalently use e2 in this formula (except it has zeros)
  like(i) = -sum(log(e1)) - (d-k)*log(v);
  % the number of well-determined params
  params = d + k*d-k*(k-1)/2 + 1;
  p(i) = like(i)*n - params*log(n);
end
[pmax,i] = max(p);
k = ks(i);

function [gap, minGap, pos]=EigenRank(eigenvalues)
l=length(eigenvalues);
for (i=1:l-1)
    if (eigenvalues(i+1)<=(eigenvalues(i)/3));
        gap(i)=eigenvalues(i+1)/(eigenvalues(i)-2*eigenvalues(i+1));
    else 
        gap(i)=1;
    end
end

[minGap,pos]=min(gap);

function [k,p] = laplace_pca(data, e, d, n)
% LAPLACE_PCA   Estimate latent dimensionality by Laplace approximation.
%
% k = LAPLACE_PCA([],e,d,n) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues e, original dimensionality d, and size n.
% LAPLACE_PCA(data) computes (e,d,n) from the matrix data 
% (data points are rows)
% [k,p] = LAPLACE_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  k is the argmax of p.

if ~isempty(data)
  [n,d] = size(data);
  m = mean(data);
  data0 = data - repmat(m, n, 1);
  e = svd(data0,0).^2;
end
e = e(:);
% break off the eigenvalues which are identically zero
i = find(e < eps);
e(i) = [];

kmax = min([d-1 n-2]);
%kmax = min([kmax 15]);
ks = 1:kmax;
% normalizing constant for the prior (from James)
% the factor of 2 is cancelled when we integrate over the 2^k possible modes
z = log(2) + (d-ks+1)/2*log(pi) - gammaln((d-ks+1)/2);
for i = 1:length(ks)
  k = ks(i);
  e1 = e(1:k);
  e2 = e((k+1):length(e));
  v = sum(e2)/(d-k);
  p(i) = -sum(log(e1)) - (d-k)*log(v);
  p(i) = p(i)*n/2 - sum(z(1:k)) - k/2*log(n);
  % compute logdet(H)
  lambda_hat = 1./[e1; repmat(v, length(e2), 1)];
  h = 0;
  for j1 = 1:k
    for j2 = (j1+1):length(e)
      h = h + log(lambda_hat(j2) - lambda_hat(j1)) + log(e(j1) - e(j2));
    end
    % count the zero eigenvalues all at once
    h = h + (d-length(e))*(log(1/v - lambda_hat(j1)) + log(e(j1)));
  end
  m = d*k-k*(k+1)/2;
  h = h + m*log(n);
  p(i) = p(i) + (m+k)/2*log(2*pi) - h/2;
end
[pmax,i] = max(p);
k = ks(i);


function [nComponents]=eigenround(d)
  maxD=max(d);
    for(i=1:30)
        if (maxD/10^i)<1
            lVal=i;
            break;
        end
    end
    bool=0;
   for(j=0:lVal)
        arr=10^(lVal-j);
        dd=d/10^(lVal);
        dArr=dd*arr;
        dArrInt=round(dArr);
        dArrInt=dArrInt/arr;
        for(i=1:length(dArrInt))
            if( i<length(dArrInt) )
                if(dArrInt(i)>dArrInt(i+1))
                    bool=0;
                else
                    bool=1;
                    break;
                end
            else
                bool=0;
            end
        end
%        if(bool==1)
%            break;
%       end
        if(bool==0)
            nComponents(j+1,1)=length(dArrInt);
            nComponents(j+1,2)=arr;
        else
        if(i==1) 
            nComponents(j+1,1)=i;
            nComponents(j+1,2)=arr;
        end
        if(i>1) 
            nComponents(j+1,1)=i-1;
            nComponents(j+1,2)=arr;
        end
    end
end