function [LL, initProbVec, transProbMat, obsProbMat, nrIterations] = ...
   learnHMM_Params(obsSeq, initProbVec, transProbMat, obsProbMat, varargin)
%my altered version of dhmm_em.m from (add URL here)
%need to inlude HMMALL in path for util functions?
%
% LEARN_DHMM Find the ML/MAP parameters of an HMM with discrete outputs using EM.
% [ll_trace, prior, transmat, obsmat, iterNr] = learn_dhmm(data, prior0, transmat0, obsmat0, ...)
%
% Notation: Q(t) = hidden state, Y(t) = observation
%
% INPUTS:
% data{ex} or data(ex,:) if all sequences have the same length - obsSeq
% prior(i) - initProbVec
% transmat(i,j)
% obsmat(i,o)
%
% Optional parameters may be passed as 'param_name', param_value pairs.
% Parameter names are shown below; default values in [] - if none, argument is mandatory.
%
% 'max_iter' - max number of EM iterations [10]
% 'thresh' - convergence threshold [1e-4]
% 'verbose' - if 1, print out loglik at every iteration [1]
% 'obs_prior_weight' - weight to apply to uniform dirichlet prior on observation matrix [0]
%
% To clamp some of the parameters, so learning does not change them:
% 'adj_prior' - if 0, do not change prior [1]
% 'adj_trans' - if 0, do not change transmat [1]
% 'adj_obs' - if 0, do not change obsmat [1]
%
% DH additions
% 'tie_trans_prbs' serves as flag and array, if not empty use it []
% 'tie_style' if 1 use max of the indices to be tied, if 2 use the mean [1]
%
%
% Modified by Herbert Jaeger so xi are not computed individually
% but only their sum (over time) as xi_summed; this is the only way how they are used
% and it saves a lot of memory.

[max_iter, thresh, verbose, obs_prior_weight, adj_prior, adj_trans, adj_obs, tie_trans_prbs, tie_emsn_prbs] = ..., tie_style] = ...
   process_options(varargin, 'max_iter', 10, 'thresh', 1e-4, 'verbose', 1, ...
                   'obs_prior_weight', 0, 'adj_prior', 1, 'adj_trans', 1, 'adj_obs', 1, 'tie_trans_prbs', [], 'tie_emsn_prbs', []); %, 'tie_style', 1); % will need at least one or two additional for tying self transitions

previous_loglik = -inf;
loglik = 0;
converged = 0;
curr_iter = 1;
LL = [];

if ~iscell(obsSeq)
 obsSeq = num2cell(obsSeq, 2); % each row gets its own cell
end

while (curr_iter <= max_iter) && ~converged
    % E step - returns expected number of observations in a stats (emit)
    % and expeected number of transistions from state i->j DH
    [loglik, exp_num_trans, exp_num_visits1, exp_num_emit] = ...
         compute_ess_dhmm(initProbVec, transProbMat, obsProbMat, obsSeq, obs_prior_weight);

    % M step
    if adj_prior
        initProbVec = normalise(exp_num_visits1);
    end
    if adj_trans && ~isempty(exp_num_trans)
        transProbMat = mk_stochastic(exp_num_trans);
        if ~isempty(tie_trans_prbs)
            
            tied_ndcs = tie_trans_prbs; % fix to each row contains those to be tied **
            
            for tp=1:size(tied_ndcs, 1)
                if tied_ndcs{tp, 4} == 1 %tie_style == 1 %use max
                    %a_i_j =  max(transProbMat(tied_ndcs{tp, 1}));
                    a_i_j =  mean(maxk(transProbMat(tied_ndcs{tp, 1}), 2));
                    if a_i_j > .9 %floor
                        a_i_j = .9;
                    end
                elseif tied_ndcs{tp, 4} == 2  %tie_style == 2
                    a_i_j =  mean(transProbMat(tied_ndcs{tp, 1}));
                elseif tied_ndcs{tp, 4} == 3
                    a_i_j =  mean(mink(transProbMat(tied_ndcs{tp, 1}), 2)); %3
                    %hard code following for now
                    if a_i_j < .005 %floor
                        a_i_j = .005;
                    end
                else
                    error('Undefined parameter tie style')
                end
                transProbMat(tied_ndcs{tp, 1}) = a_i_j;
                %for now this is true, but smarter more flexiable way to
                %do.. anon func?
                %transProbMat(tied_ndcs{tp, 2}) = 1 - a_i_j;
                compliment_func = tied_ndcs{tp, 3};
                transProbMat(tied_ndcs{tp, 2}) = compliment_func(a_i_j);
            end
            %transProbMat = mk_stochastic(transProbMat); % doesn't work for column one
            %off diag after 1st rw should remain 0 on own ** then instead
            %of this do something similar to normalise or stocastic Or
            %maybe just including with style works if select max of first
            %column should work but what about average 
%             transProbMat(tied_ndcs) = a_i_j;
%             transProbMat(2:length(transProbMat), 1) = 1 - a_i_j;
        end  
    end
    if adj_obs
        obsProbMat = mk_stochastic(exp_num_emit);
        if ~isempty(tie_emsn_prbs)
            tied_ndcs = tie_emsn_prbs;
            
            for tp=1:size(tied_ndcs, 1)
                if tied_ndcs{tp, 2} == 1 %tie_style == 1 %use max
                    a_i_j =  max(obsProbMat(tied_ndcs{tp, 1}));
                elseif tied_ndcs{tp, 2} == 2  %tie_style == 2
                    a_i_j =  mean(obsProbMat(tied_ndcs{tp, 1}));
                elseif tied_ndcs{tp, 2} == 3
                    a_i_j =  min(obsProbMat(tied_ndcs{tp, 1}));
                else
                    error('Undefined parameter tie style: emission')
                end
                obsProbMat(tied_ndcs{tp, 1}) = a_i_j;
            end
        end
    end

    if verbose, fprintf(1, 'iteration %d, loglik = %f\n', curr_iter, loglik); end
    curr_iter =  curr_iter + 1;
    converged = em_converged(loglik, previous_loglik, thresh);
    previous_loglik = loglik;
    LL = [LL loglik];
end
nrIterations = curr_iter - 1;

%%%%%%%%%%%%%%%%%%%%%%%

function [loglik, exp_num_trans, exp_num_visits1, exp_num_emit, exp_num_visitsT] = ...
   compute_ess_dhmm(startprob, transmat, obsmat, data, dirichlet)
% COMPUTE_ESS_DHMM Compute the Expected Sufficient Statistics for an HMM with discrete outputs
% function [loglik, exp_num_trans, exp_num_visits1, exp_num_emit, exp_num_visitsT] = ...
%    compute_ess_dhmm(startprob, transmat, obsmat, data, dirichlet)
%
% INPUTS:
% startprob(i)
% transmat(i,j)
% obsmat(i,o)
% data{seq}(t)
% dirichlet - weighting term for uniform dirichlet prior on expected emissions
%
% OUTPUTS:
% exp_num_trans(i,j) = sum_l sum_{t=2}^T Pr(X(t-1) = i, X(t) = j| Obs(l))
% exp_num_visits1(i) = sum_l Pr(X(1)=i | Obs(l))
% exp_num_visitsT(i) = sum_l Pr(X(T)=i | Obs(l))
% exp_num_emit(i,o) = sum_l sum_{t=1}^T Pr(X(t) = i, O(t)=o| Obs(l))
% where Obs(l) = O_1 .. O_T for sequence l.

numex = length(data); % sequence length, num observations - DH
[S O] = size(obsmat); % S is number of states - DH
exp_num_trans = zeros(S,S);  %expected value of transition matrix
exp_num_visits1 = zeros(S,1); % ?
exp_num_visitsT = zeros(S,1); % ?
exp_num_emit = dirichlet*ones(S,O);
loglik = 0;

for n=1:numex % number examples?
 obs = data{n}; 
 T = length(obs); % one for a single long sequence
 %obslik = eval_pdf_cond_multinomial(obs, obsmat);
 obslik = multinomial_prob(obs, obsmat); % returns probability/likelihood of symbol for each event/time in sequence (for all states)
 [alpha, beta, gamma, current_ll, xi_summed] = fwdback(startprob, transmat, obslik);

 loglik = loglik +  current_ll;
 exp_num_trans = exp_num_trans + xi_summed;
 exp_num_visits1 = exp_num_visits1 + gamma(:,1);
 exp_num_visitsT = exp_num_visitsT + gamma(:,T);
 % loop over whichever is shorter
 if T < O
   for t=1:T
     o = obs(t);
     exp_num_emit(:,o) = exp_num_emit(:,o) + gamma(:,t);
   end
 else
   for o=1:O
     ndx = find(obs==o);
     if ~isempty(ndx)
       exp_num_emit(:,o) = exp_num_emit(:,o) + sum(gamma(:, ndx), 2);
     end
   end
 end
end