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


%RL
prior_RL = struct('mean',zeros(2,1),'variance',v);
%fname_RL = 'lap_RL_v100.mat';
fname_RL = 'lap_RL_v6p25_singleupdate.mat';
cbm_lap(data,@fit_rl, prior_RL,fname_RL);

%winloss RL
prior_dualRL = struct('mean',zeros(3,1),'variance',v);
%fname_dualRL = 'lap_dualRL_v100.mat';
fname_dualRL = 'lap_dualRL_v6p25.mat';
cbm_lap(data,@fit_2rl, prior_dualRL,fname_dualRL);

% 
% %hgf2
% prior_hgf2 = struct('mean',zeros(3,1),'variance',v);
% fname_hgf2 = 'lap_hgf2.mat';
% cbm_lap(data,@fit_hgf2, prior_hgf2,fname_hgf2);
% 
% 
% %hgf3
% prior_hgf3 = struct('mean',zeros(4,1),'variance',v);
% fname_hgf3 = 'lap_hgf3.mat';
% cbm_lap(data,@fit_hgf3, prior_hgf3,fname_hgf3);
% 
% %kf
% prior_kf = struct('mean',zeros(3,1),'variance',v);
% fname_kf = 'lap_kf.mat';
% cbm_lap(data,@fit_kf, prior_kf,fname_kf);
% %vkf
% prior_vkf = struct('mean',zeros(4,1),'variance',v);
% fname_vkf = 'lap_vkf.mat';
% cbm_lap(data,@fit_vkf, prior_vkf,fname_vkf);
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