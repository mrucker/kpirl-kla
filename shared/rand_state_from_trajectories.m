function [rand_state] = rand_state_from_trajectories(trajectories)

    trajectory_count  = numel(trajectories);
    trajectory_length = size(trajectories{1},2);

    rand_trajectory = randi(trajectory_count);
    rand_state      = randi(trajectory_length);   

    rand_state = trajectories{rand_trajectory}{rand_state};
end