function [loglik, output] = fit_vkf(params,data)

lux      = @(x)(1/(1+exp(-x)));
% lambda   = lux(params(1));
% v0       = lux(params(2));
lambda   = lux(params(1));
 v0       = 10*lux(params(2));
omega    = exp(params(3));
params_response = params(4);

choice   = data.choice;
outcome  = data.outcome;

[~,~,~,um]  = vkf_bin(outcome,lambda,v0,omega);


% Y        = choice==1;
[loglik, beta]   = fit_A_response(um,choice,params_response);

if nargout>1
    output = struct('outcome',outcome,'lambda',lambda,'v0',v0,'omega',omega,'beta',beta);
end

end

