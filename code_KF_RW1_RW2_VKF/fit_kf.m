function [loglik] = fit_kf(params,data)
lux      = @(x)(1/(1+exp(-x)));
sigma    = lux(params(1));
omega    = lux(params(2));
params_response = params(3);

choice   = data.choice;
outcome  = data.outcome;


[dv]  = kf(outcome,sigma,omega);
dv    = dv;%2*dv-1;

% Y        = choice==1;
loglik   = fit_A_response(dv,choice,params_response);
end
% 
function dv = kf(y,sigma,omega)

[nt,nq] = size(y);

m       = zeros(1,nq)+0.33;
w       = sigma*ones(1,nq);
dv      = nan(nt,nq);
for t  = 1:nt     
    
    dv(t,:)     = (m(1,:));
        
    k           = (w+sigma)./(w+sigma + omega);
    delta       = y(t,:) - m;
    m           = m + k.*delta;
    w           = (1-k).*(w+sigma);

end



end
