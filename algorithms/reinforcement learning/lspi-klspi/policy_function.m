function [action] = policy_function(policy, state)

  valid_actions = policy.actions(state);

  if (rand < policy.explore)
    action = valid_actions(:,randi(size(valid_actions,2)));
  else
    
    if isfield(policy, 'exemplars')
        phis = policy.basis(state, valid_actions);
        phis = policy.affin(phis, policy.exemplars);
    else
        phis = policy.basis(state, valid_actions);
    end
    
    q_all = phis * policy.weights;    
    q_max = max(q_all);
    i_max = find(q_all == q_max);
    
    random_index_of_max_q = i_max(randi(length(i_max)));

    action  = valid_actions(:,random_index_of_max_q);
  end
  
  
  return
