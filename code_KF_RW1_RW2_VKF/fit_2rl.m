function [loglik] = fit_2rl(params,data)

ux       = @(x)(1/(1+exp(-x)));
alphaW    = ux(params(1));
alphaL    = ux(params(2));
params_response = params(3);

choice   = data.choice;
outcome  = data.outcome;

[dv]     = model_2rl(alphaW,alphaL,choice,outcome);

% Y        = choice==1;

[loglik] = fit_A_response(dv,choice,params_response);
end

function dv = model_2rl(alphaW,alphaL,actions,outcome)
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
    
    if (delta(1,actions(t))>=0)
    q(:,actions(t)) = q(:,actions(t)) + alphaW.*delta(:,actions(t));
%     q(:,2) = q(:,2) + alphaW.*delta(:,2);
%     q(:,3) = q(:,3) + alphaW.*delta(:,3);
    end
    

    if (delta(1,actions(t))<0 )
        q(:,actions(t)) = q(:,actions(t)) + alphaL.*delta(:,actions(t));
%     q(:,1) = q(:,1) + alphaL.*delta(:,1);
%     q(:,2) = q(:,2) + alphaL.*delta(:,2);        
%      q(:,3) = q(:,3) + alphaL.*delta(:,3);   
    end

    
end

end
