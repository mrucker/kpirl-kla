function episodes = krand_reward_episodes(reward)

    domain = 'krand';

    [ ~, ~, t_b] = feval([domain '_transitions']);
    [s_1       ] = feval([domain '_initiator']);
    [parameters] = feval([domain '_parameters']);

    epi_count  = parameters.samples;
	epi_length = parameters.steps;

    policy   = kla_mem(domain, reward);
    episodes = policy2episodes(policy, t_b, s_1, epi_count, epi_length);
end