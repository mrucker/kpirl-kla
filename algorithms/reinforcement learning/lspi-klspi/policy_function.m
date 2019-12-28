function [a, f] = policy_function(policy, state)

    as = policy.actions(state);
    fs = policy.feats(state, as);

    if (rand < policy.explore)    
        qs = rand(1,size(fs,2));
    else
        qs = policy.weights' * policy.basis(fs);
    end
    
    [~, i] = randargmax(qs);
    
    f = fs(:,i);
    a = as(:,i);
end

