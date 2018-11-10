%Be careful, if states is too big, realizing the whole policy may overload memory.
%Also, this assumes that reward is not dependent on action. If it is this won't work.
function a = best_action_from_state(state, actions, post, value)
        
    post_states = post(state, actions);
    post_values = value(post_states);
    post_max_i  = max_i(post_values);

    a = actions(:,post_max_i);
end

function i = max_i(values)
    [~, i] = max(values);
end