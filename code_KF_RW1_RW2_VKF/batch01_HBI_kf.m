clear all;
close all;
addpath(genpath('W:\6_SEEG_Bandit\1_Analysis_banditOnline\2_ANALYSIS_VKF\cbm-master\codes'));
fdata = load('alldatabandit.mat');
data = fdata.alldata;
% 2nd input: a cell input containing function handle to models
models = {@fit_rl, @fit_2rl,@fit_hgf2,@fit_hgf3,@fit_kf,@fit_vkf};
% note that by handle, I mean @ before the name of the function
% 3rd input: another cell input containing file-address to files saved by cbm_lap


v=6.25;

%kf
% prior_kf = struct('mean',zeros(3,1),'variance',v);
% fname_kf = 'lap_kf2.mat';
% cbm_lap(data,@fit_kf, prior_kf,fname_kf);



%kf with loss/win sigma/omega
prior_kf = struct('mean',zeros(3,1),'variance',v);
fname_kf= 'lap_kf_v6p25.mat';
cbm_lap(data,@fit_kf, prior_kf,fname_kf);

% 
% 
% %% collect the output for each single model
% fcbm_maps = {'lap_RL.mat','lap_dualRL.mat','lap_hgf2.mat','lap_hgf3.mat'};
% % note that they corresponds to models (so pay attention to the order)
% % 4th input: a file address for saving the output
% fname_hbi = 'hbi_RL_dualRL.mat';
% 
% %% run the final group comparison, the final step to select better model
% cbm_hbi(data,models,fcbm_maps,fname_hbi);
% % Running this command, prints a report on