function [s_1] = rem_random()

    trajectories = rem_trajectories();
    paramaters   = huge_paramaters();

    trajectory_count  = numel(trajectories);
    trajectory_length = size(trajectories{1},2);

    rand_states = arrayfun(@(i) trajectories{randi(trajectory_count)}{randi(trajectory_length)}, 1:paramaters.rand_ns, 'UniformOutput', false);

    s_1 = @() rand_states{randi(paramaters.rand_ns)};
end

function state = random_state()
    [paramaters] = rem_paramaters();
    [a_v, a_m  ] = rem_actions();

    a_n   = randi(paramaters.max_hist);
    state = zeros(2*a_n,1);

    for i = 1:a_n
        
        if i == 1
            actions = a_m(:,randi(size(a_m,2)));
        else
            actions = a_v(state(1:(i-1)*2)); %is this right????
        end
        
        state(2*(i-1) + (1:2)) = actions(:,randi(size(actions,2)));
    end
end