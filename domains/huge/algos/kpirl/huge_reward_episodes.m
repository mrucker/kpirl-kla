function episodes = huge_reward_episodes(reward)

    domain = 'huge';

    [t_s   ] = feval([domain '_transitions']);
    [s_1   ] = feval([domain '_initiator']);
    [params] = feval([domain '_parameters']);

    epi_count  = params.samples;
    epi_length = params.steps;

    policy   = kla_spd(domain, reward);
    
    episodes = policy2episodes(policy, t_s, s_1, epi_count, epi_length);
end