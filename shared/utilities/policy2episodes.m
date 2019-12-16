function [episodes] = policy2episodes(policy, transition, episode_starter, episode_count, episode_length)

    episodes = cell(1, episode_count);

    for t = 1:episode_count
        episode    = cell(1, episode_length);
        episode{1} = episode_starter();

        for s = 2:episode_length
            episode{s} = transition(episode{s-1}, policy(episode{s-1}));
        end

        episodes{t} = episode;
    end
end