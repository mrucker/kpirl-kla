function s_1 = huge_random()
    trajectories = huge_trajectories();
    paramaters   = huge_paramaters();

    trajectory_count  = numel(trajectories);
    trajectory_length = size(trajectories{1},2);

    rand_states = arrayfun(@(i) trajectories{randi(trajectory_count)}{randi(trajectory_length)}, 1:paramaters.rand_ns, 'UniformOutput', false);

    s_1 = @() rand_states{randi(paramaters.rand_ns)};
end