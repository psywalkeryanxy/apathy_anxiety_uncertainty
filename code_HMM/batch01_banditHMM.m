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


for subIDX = 1:length(alldatafiles)
    
    %load  subdata
    thissub = xlsread([rawdatapath,filesep,alldatafiles(subIDX).name]);
    
    choice_raw = thissub(26:end,7);%exclue practical trials
    choice_seq = choice_raw+1;
    
    %% HMM here
    num_arms = 3;
    [Loglik,state_seq,trnx_est,emsn_est]  = estimate3ArmBanditChoiceStates(num_arms, choice_seq);
    %save them
    resultsHMM.state_seq = state_seq;
    resultsHMM.trnx_est = trnx_est;
    resultsHMM.emsn_est = emsn_est;
    
    allLoglik = [allLoglik;Loglik(end)];
    clear Loglik
    %% Now getting the stationary prob for each state, left eigenvector with eigenvalue = 1
    %make sure the P(i.e., trasition matrix, sum(row)_i = 1; i == #row
    %Identity matrix
    I = eye(size(trnx_est));
    Y = null(trnx_est'-I);
    PI = Y./(sum(Y));
    
    %so for the 1st row of PI, that's for explore
    %for the 2nd-end row of PI, that's for exploit
    %then we have:
    
    resultsHMM.state.explore = PI(1);
    resultsHMM.state.exploit = sum(PI(2:end,1));
    %According to Bolzman equation from Cathy's 2021 eLife paper (page 18/24)
    %We can calculate the relative energy of E(explore) & E(exploit)
    %setting all parameter into constant, 1
    %so we have
    resultsHMM.E.explore = -log(resultsHMM.state.explore);
    resultsHMM.E.exploit = -log(resultsHMM.state.exploit);
    
    %% combine the decoded state into
    
    %% dwell time
    winlen = length( state_seq );
    count_dwellExplore = zeros(1,winlen-1);
    count_dwellExploit = zeros(1,winlen-1);
    
    
    thissub_state = state_seq;
    
    for kk=1:length(thissub_state)-1
        %explore dwell time
        if thissub_state(kk) ==1 && thissub_state(kk)==thissub_state(kk+1)
            count_dwellExplore(1,kk)=1;
        end
        %exploit dwell time
        if thissub_state(kk) ==0 && thissub_state(kk)==thissub_state(kk+1)
            count_dwellExploit(1,kk)=1;
        end
        
    end%for kk
    
    
    
    
    resultsHMM.alldw = [sum(count_dwellExplore),sum(count_dwellExploit)];
    
    resultsHMM.dwell_relative = sum(count_dwellExplore)/sum(count_dwellExploit);
    
    %% p(explore)/p(exploit) across whole state seq
    
    resultsHMM.Pexplore = sum(state_seq)/300;
    resultsHMM.Pexploit = 1 - sum(state_seq)/300;
    steady_explore = [steady_explore;resultsHMM.state.explore];
    steady_exploit = [steady_exploit;resultsHMM.state.exploit];
    
    cd([rootpath]);
    
    

end% for subIDX = 1:length(alldatafiles)



