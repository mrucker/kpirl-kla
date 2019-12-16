function [s_1] = krand_initiator()

    episodes = krand_expert_episodes();

    s_1 = @() random_state(random_episode(episodes));
end

function s = random_state(trajectory)
    s = trajectory(randi(size(trajectory,2)));
end

function t = random_episode(episodes)
    t = episodes{randi(size(episodes,2))};
end