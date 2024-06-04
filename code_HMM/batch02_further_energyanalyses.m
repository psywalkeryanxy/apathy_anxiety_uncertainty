% Xin-Yuan Yan
% HD Lab
% yan00286@umn.edu

%HMM for online 3 Arm bandit
%with further analysis

clear all;
close all;

addpath 'C:\Users\yan00286\HDLab_XY\2_Digging_models\1_all_DDMs\1_HMMEE_DDM\HMM'
rawdatapath = 'C:\Users\yan00286\HDLab_XY\2_Digging_models\combo_Bandit_subjects_raw';
alldatafiles = dir([rawdatapath,filesep,'subject*']);
rootpath = pwd;

resultsHMM = struct;
allLoglik = [];

steady_explore = [];
steady_exploit = [];

trnx_est= cell(1,length(alldatafiles));
steady_state = cell(1,length(alldatafiles));
for subIDX = 1:length(alldatafiles)
    
    %load  subdata
    thissub = xlsread([rawdatapath,filesep,alldatafiles(subIDX).name]);
    
    choice_raw = thissub(26:end,7);%exclue practical trials
    choice_seq = choice_raw+1;
    
    %% HMM here
    num_arms = 3;
    [Loglik,state_seq,trnx_est{subIDX},emsn_est]  = estimate3ArmBanditChoiceStates(num_arms, choice_seq);
    steady_state{subIDX}=stationaryDist(trnx_est{subIDX});
    
end% for subIDX = 1:length(alldatafiles)
%%

avg_transmat = nanmean(cat(3,trnx_est{:}),3);

avg_stationaryDist = stationaryDist(avg_transmat);

figure();
% twoWellPotential([avg_stationaryDist(1),avg_stationaryDist(2)],1-avg_transmat(1,1:2))

all_deltaG = [];
all_Eball = [];

for subIDX = 1:length(alldatafiles)
    pi = [sum(steady_state{1,subIDX}(2:end));steady_state{1,subIDX}(1)];%exploit explore
    k_explore_exploit = sum(trnx_est{1,subIDX}(1,2:4));
    [deltaG,E_b1] = get_energyIDX(pi,k_explore_exploit);
    k_exploit_explore = sum(trnx_est{1,subIDX}(2,1));
    [~,E_b2] = get_energyIDX(pi,k_exploit_explore);   
    all_deltaG = [all_deltaG;deltaG];
all_Eball = [all_Eball;E_b1+E_b2];

end% for subIDX
