function s_1 = huge_random()
    trajectories = huge_expert_trajectories();
    parameters   = huge_parameters();

    trajectory_count  = numel(trajectories);
    trajectory_length = numel(trajectories{1});

    n_rand_states = parameters.n_random;
    
    rand_states = cell(n_rand_states, 1);
    
    for i = 1:n_rand_states
        rand_states{i} = trajectories{randi(trajectory_count)}{randi(trajectory_length)};
    end
    
    s_1 = @() rand_states{randi(numel(rand_states))};
end