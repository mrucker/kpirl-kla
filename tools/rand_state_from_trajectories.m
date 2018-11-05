function [rand_state] = rand_state_from_trajectories(trajectories)

    trajectory_count  = numel(trajectories);
    trajectory_length = size(trajectories{1},2);

    trajectory_states = horzcat(trajectories{:});
    trajectory_starts = trajectory_states(1:trajectory_length:trajectory_count*trajectory_length);

    rand_state = trajectory_starts{randi(numel(trajectory_starts))};
end