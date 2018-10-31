function [action, actionphi] = k_policy_function(policy, state, Dic, para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exploration or not? 
if (rand < policy.explore)
    % Pick one action in random
    action = ceil(rand*policy.actions);
    if para ==0
        actionphi =1;%  feval(policy.basis, state, action);
    else
        actionphi =1; % feval(policy.basis, state, action, Dic, para)
    end
else

    phis = feval(policy.basis, state, 1:policy.actions, Dic, para);
    
    if(size(policy.weights,1) > 1 || policy.weights ~= 0)
        qs = phis' * policy.weights;
    else
        qs = zeros(1, policy.actions); 
    end
    
    [~,qi] = max(qs);
    
    action    = qi;
    actionphi = phis(:,qi);
end
return
