function s_1 = huge_random()
    trajectories = huge_trajectories();
    s_1 = @() rand_state_from_trajectories(trajectories);
end