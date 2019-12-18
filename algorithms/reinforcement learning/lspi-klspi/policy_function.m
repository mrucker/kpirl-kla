function [action, feats] = policy_function(policy, state)

    actions = policy.actions(state);

    if (rand < policy.explore)
        action = actions(:,randi(size(actions,2)));
        feats  = policy.feats(state, action);
    else
        feats = policy.feats(state, actions);

        [~, i] = randmax(policy.weights' * policy.basis(feats));
                
        action = actions(:,i);
        feats  = feats(:,i);
    end
end
