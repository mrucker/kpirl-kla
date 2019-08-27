function a = best_action_from_state(state, actions, post, value)
        
    post_states = post(state, actions);
    post_values = value(post_states);
    post_max_i  = max_i(post_values);

    a = actions(:,post_max_i);
end

function i = max_i(values)
    i = find(values == max(values));
    i = i(randi(numel(i)));
end