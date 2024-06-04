
clear all;close all;

addpath(genpath('W:\6_SEEG_Bandit\1_Analysis_banditOnline\2_ANALYSIS_VKF\analysis_code_3options'));
load('results_kf_v6p25.mat');

for whichcue=1:3
    figure(99);
    screensize = get( groot, 'Screensize' );
    ResolutionVal = 1200;
    set(gcf, 'Position', [screensize(1),screensize(2),screensize(3),screensize(4)]*0.5);
    
    exampleSub=200;
    
    
    if whichcue==1
        
        value_model = allsubval_1(exampleSub,:);
        temp_allsub_choice = alldata{exampleSub,1}.choice;
        temp_allsub_choice(find(temp_allsub_choice~=1))=0;
        realchoice = temp_allsub_choice;
        subplot(3,1,whichcue)
        plot(value_model);hold on
        plot(realchoice);
        ylim([-0.1,1.1]);
        %plot_bandit_results(value_model,realchoice)
        hold on
        
        
    end
    
    if whichcue==2
        
        value_model =  allsubval_2(exampleSub,:);
        temp_allsub_choice = alldata{exampleSub,1}.choice-1;
        temp_allsub_choice(find(temp_allsub_choice~=1))=0;
        realchoice = temp_allsub_choice;
        
        subplot(3,1,whichcue)
        plot(value_model);hold on
        plot(realchoice);
        ylim([-0.1,1.1]);
        %plot_bandit_results(value_model,realchoice)
        hold on
        
        
    end
    
    
    if whichcue==3
        
        value_model =  allsubval_3(exampleSub,:);
        temp_allsub_choice = alldata{exampleSub,1}.choice-2;
        temp_allsub_choice(find(temp_allsub_choice~=1))=0;
        realchoice = temp_allsub_choice;
        
        subplot(3,1,whichcue)
        plot(value_model);hold on
        plot(realchoice);
        ylim([-0.1,1.1]);
        %plot_bandit_results(value_model,realchoice)
        hold on
    end
    
    

    
    
    
end