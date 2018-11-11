function [action, actionphi] = k_policy_function(policy, state, Dic, para)

    valid_actions = policy.actions(state);

    if (rand < policy.explore)
        % Pick one action in random
        action = valid_actions(:,randi(size(valid_actions,2)));
        if para ==0
            actionphi =1;%  feval(policy.basis, state, action);
        else
            actionphi =1; % feval(policy.basis, state, action, Dic, para)
        end
    else

        phis = feval(policy.basis, state, valid_actions, Dic, para);

        if(size(policy.weights,1) > 1 || policy.weights ~= 0)
            qs = phis' * policy.weights;
        else
            qs = zeros(1, size(valid_actions,2)); 
        end

        [~,qi] = max(qs);

        action    = qi;
        actionphi = phis(:,qi);
    end
return
