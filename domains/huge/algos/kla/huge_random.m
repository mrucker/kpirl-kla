function s_1 = huge_random()
    trajectories = huge_expert_trajectories();
    parameters   = huge_parameters();

    trajectory_count  = numel(trajectories);
    trajectory_length = size(trajectories{1},2);

    rand_states = arrayfun(@(i) trajectories{randi(trajectory_count)}{randi(trajectory_length)}, 1:parameters.rand_ns, 'UniformOutput', false);

    s_1 = @() rand_states{randi(parameters.rand_ns)};
end