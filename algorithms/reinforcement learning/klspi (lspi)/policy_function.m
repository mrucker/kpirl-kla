function [a, f] = policy_function(policy, state)
    actions = policy.actions(state);

    if (rand < policy.explore)
        q_vals = zeros(1,size(actions,2));
    else
        q_vals = policy.weights' * policy.basis(policy.feats(state, actions));
    end
    
    [~, i] = randargmax(@(as) q_vals, actions);
    
    a = actions(:,i);
    f = policy.feats(state, a);
end

