function [loglik] = fit_rl(params,data)

ux       = @(x)(1/(1+exp(-x)));
alpha    = ux(params(1));
params_response = params(2);

choice   = data.choice;
outcome  = data.outcome;

[dv]     = model_rl(alpha,choice,outcome);

%Y        = choice==1;
[loglik] = fit_A_response(dv,choice,params_response);
end

function dv = model_rl(alpha,actions,outcome)
Q      = size(outcome,2);
N      = size(outcome,1);

q       = ones(1,Q)*0.33;
dv      = nan(N,Q);

for t = 1:N
    dv(t,:) = [q(:,1),q(:,2),q(:,3)];
    
    a      = actions(t,:);    
    o      = outcome(t,:);
   % idx    = sub2ind([2 Q],a,(1:Q));
       
    delta  = o - q;
%     q(:,1) = q(:,1) + alpha.*delta(:,1); 
%     q(:,2) = q(:,2) + alpha.*delta(:,2); 
%     q(:,3) = q(:,3) + alpha.*delta(:,3); 
      q(:,actions(t)) = q(:,actions(t)) + alpha.*delta(:,actions(t));
end

end
