function banditPerformance = calculateBanditPerfomance(behaviorData,behaviorDataParams,behaviorDataDir,reimport)
%function calculates performance for the bandit task from already imported
%behavior data or, can reimport from files themselves.
%
% Inputs:
%   1) behaviorData: behavior data structure or table for this task. Set to empty if you want to reimport.
%   2) behaviorDataParams: behavior data parameters. Set to empty if you want to reimport.
%   3) behaviorDataDir: data directory for behavior data. Set to empty if you don't want to reimport.
%   4) reimport:  true/false flag for reimporting
%
% Outputs:
%   1) banditPerformance: structure containing bandit performance.
%
% Written by Seth Konig 3/1/2.

%---Re-Import the Data if Desired---%
taskName = 'Bandit';
if reimport
    %get task date and then re-import
    [taskDate,~] = getTaskDate(behaviorDataDir);
    [behaviorData,behaviorDataParams,taskProgram] = ...
        importBehaviorData([],[],{behaviorDataDir},1,taskDate,taskName,false);
end

%remove cell structure, if exist
if iscell(behaviorData)
    behaviorData = behaviorData{1};
    behaviorDataParams = behaviorDataParams{1};
end



%---Get Task Performance---%
numTrials = length(behaviorData);

numCompletedTrials = 0; 
numRewardTrials = 0;
reactionTimes = NaN(1,length(behaviorData));
choosenStimulus = NaN(1,length(behaviorData));
for trial = 1:length(behaviorData)
    if isfield(behaviorData{trial},'completed') %newer version
        if behaviorData{trial}.completed == 1 %completed trial
            numCompletedTrials = numCompletedTrials+1;
            numRewardTrials = numRewardTrials+behaviorData{trial}.rewarded;
            reactionTimes(trial) = behaviorData{trial}.targAcq-behaviorData{trial}.targOn;
            choosenStimulus(trial) = behaviorData{trial}.choiceMade;
        end
    else
        if behaviorData{trial}.correct == 1 %completed trial
            numCompletedTrials = numCompletedTrials+1;
            numRewardTrials = numRewardTrials+behaviorData{trial}.rewarded;
            reactionTimes(trial) = behaviorData{trial}.targAcq-behaviorData{trial}.targOn;
            choosenStimulus(trial) = behaviorData{trial}.choice;
        end
    end
end



%---Store Output---%
banditPerformance = [];
banditPerformance.numTrials = numTrials;
banditPerformance.numCompletedTrials = numCompletedTrials;

%overal performance (proportion correct) and reaction time
banditPerformance.proportionCompleted = numCompletedTrials/numTrials;
banditPerformance.overallPerformance = numRewardTrials/numCompletedTrials;
banditPerformance.overallRT = nanmean(reactionTimes);
banditPerformance.choiceVariability = nanstd(choosenStimulus); %there are probably better options

end