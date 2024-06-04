function [pi_star] = stationaryDist(A)
%STATIONARYDIST Calculate the stationary distribution of matrix A
%   This is using the Resnick 1992 method described in K. Murphy, p 599

% make a new matrix, I - A
M = eye(size(A))-A;

% replace one of its columns with 1
M(:,end) = deal(1);

% define R vector, w/ 1 where the 1 column is, 0s elsewhere
r = zeros(1,size(M,2));
r(end) = 1;

% now we must solve: pi * M = r
pi_star = linsolve(M',r');

end

