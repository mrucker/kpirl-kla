function [s_1] = krand_random()

    trajectories = krand_expert_trajectories();

    s_1 = @() random_state(random_trajectory(trajectories));
end

function s = random_state(trajectory)
    s = trajectory(randi(size(trajectory,2)));
end

function t = random_trajectory(trajectories)
    t = trajectories{randi(size(trajectories,2))};
end