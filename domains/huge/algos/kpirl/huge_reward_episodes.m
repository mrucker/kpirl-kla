function episodes = huge_reward_episodes(reward)

    domain = 'huge';

    [ ~, ~, t_b] = feval([domain '_transitions']);
    [s_1       ] = feval([domain '_initiator']);
    [parameters] = feval([domain '_parameters']);

    epi_count  = parameters.samples;
    epi_length = parameters.steps;

    policy   = kla_spd(domain, reward);
    episodes = policy2episodes(policy, t_b, s_1, epi_count, epi_length);
end