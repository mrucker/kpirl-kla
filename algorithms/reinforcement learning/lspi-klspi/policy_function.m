function [action, basis] = policy_function(policy, state)

    actions = policy.actions(state);

    if (rand < policy.explore)
        action = actions(:,randi(size(actions,2)));
        basis  = policy.basis(state, action);
    else
        if isfield(policy, 'exemplars')
            basis = policy.basis(state, actions);
            phis  = policy.affin(basis, policy.exemplars);
        else
            basis = policy.basis(state, actions);
            phis  = basis;
        end

        q_all = phis * policy.weights;
        q_max = max(q_all);
        i_max = find(q_all == q_max);

        random_index_of_max_q = i_max(randi(length(i_max)));

        action = actions(:,random_index_of_max_q);
        basis  = basis(random_index_of_max_q,:);
    end
end
