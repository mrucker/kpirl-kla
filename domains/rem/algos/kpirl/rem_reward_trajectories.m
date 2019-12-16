function trajectories = rem_reward_trajectories(reward)

    domain = 'rem';

    [ ~, ~, t_b] = feval([domain '_transitions']);
    [s_1       ] = feval([domain '_initiator']);
    [parameters] = feval([domain '_parameters']);

    epi_count  = parameters.samples;
	epi_length = parameters.steps;

    policy       = kla_spd(domain, reward);
    trajectories = policy2episodes(policy, t_b, s_1, epi_count, epi_length);
end