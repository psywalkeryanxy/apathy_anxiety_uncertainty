function [Loglik,state_seq,trnx_est,emsn_est] = estimate3ArmBanditChoiceStates(numArms, choiceSeq)
%Description
%
%
% Inputs:
%   1) numArms: number of arms in bandit task
%   2) choiceSeq: participant's choice sequence vector
% Outputs:
%   1) state_seq: vector containing explore/exploit labels for choice sequence. 1 is explore, 0 is exploit  
%
% Written by Dameon Harrell 12/27/21.

addpath(genpath('HMM'))

[init_state_dist, trnx_init, emsn_init, tied_params, emsn_tied_params] = initializeHMM_ParamsMats(numArms);

if min(choiceSeq) == 0
    choiceSeq = choiceSeq + 1;
end

if ~isrow(choiceSeq)
    choiceSeq = choiceSeq.'; 
end

[Loglik, ~, trnx_est, emsn_est, ~] = learnHMM_Params(choiceSeq, init_state_dist, trnx_init, emsn_init, 'max_iter', 200, 'verbose', 0, 'adj_prior', 0, 'tie_trans_prbs', tied_params, 'tie_emsn_prbs', emsn_tied_params);
%use the estimated transition and emission probabilities to determine the
%state (xplr vs xplt) sequence
state_seq = hmmviterbi(choiceSeq, trnx_est, emsn_est);
state_seq(state_seq ~= 1) = 0;
end

function [init_state_dist, trnx_init, emsn_init, tied_params, emsn_tied_params] = initializeHMM_ParamsMats(num_arms)
% HMM initialization
%self transition explore state seed
TP_xplr_xplr = 1/(num_arms  + 1);
TP_xplr_xplt =  TP_xplr_xplr;
    
%self transition probability exploit state seed
TP_xplt_xplt  = .75;
TP_xplt_xplr = (1 - TP_xplt_xplt);    
    
row_one = TP_xplr_xplt * ones(1, (num_arms  + 1));
tmp = diag(TP_xplt_xplt * ones(num_arms, 1));
tmp = [(TP_xplt_xplr * ones(num_arms, 1)) tmp];
trnx_init = [row_one ; tmp];

emsn_init = [(1/num_arms)*ones(1, num_arms) ; eye(num_arms)];
    
init_state_dist =[1 zeros(1, num_arms)].'; % always begin exploring 
num_states = length(trnx_init);
diag_ndx = (1 + (num_states + 1)):(num_states + 1):num_states^2;
tied_params = cell(2, 4);
tied_params{1, 1} = diag_ndx;
tied_params{1, 2} = sub2ind([(num_arms + 1) (num_arms + 1)], 2:(num_arms+1), ones(1, num_arms));
col_one_func = @(x) 1 - x;
tied_params{1, 3} = col_one_func;
tied_params{1, 4} = 1; % max of tied 
explr_2_explt_ndcs = sub2ind([(num_arms + 1) (num_arms + 1)], ones(1, num_arms), 2:(num_arms+1));
tied_params{2, 1} = explr_2_explt_ndcs;
tied_params{2, 2} = 1;
explr_explr_func =  @(x) 1 - (x*num_arms);
tied_params{2, 3} = explr_explr_func; 
tied_params{2, 4} = 3; 

emsn_tied_params = cell(1, 2);
emsn_tied_params{1, 1} = sub2ind(size(emsn_init), ones(1, num_arms), 1:num_arms);
emsn_tied_params{1, 2} = 2;
end