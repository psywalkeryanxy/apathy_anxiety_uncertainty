clear all;close all;
load('allLME_v6p25.mat')
[alpha,exp_r,xp,pxp,bor] = spm_BMS (allLME);
x=categorical({'RW','dual RW','kalman filter','volatile kalman filter'});
bar(x,pxp);
ylabel('protected exceedance probabilities');
xlabel('models');
  