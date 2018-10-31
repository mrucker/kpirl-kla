%Be careful, if states is too big, realizing the whole policy may overload memory.
%Also, this assumes that reward is not dependent on action. If it is this won't work.
function P = policy_vector_post(states, actions, post_Vf, post_trans)
    
    post_Qf = zeros(size(states,2),size(actions,2));
    
    for a_i = 1:size(actions,2)
        post_states    = post_trans(states, actions(:,a_i));
        post_Qf(:,a_i) = post_Vf(post_states);
    end

    [~, P] = max(post_Qf, [], 2);
end