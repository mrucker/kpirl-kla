function trajectories = krand_reward_trajectories(reward)

    domain = 'krand';

    [  ~,   ~, t_b] = feval([domain '_transitions']);
    [s_1          ] = feval([domain '_random']);
    [parameters   ] = feval([domain '_parameters']);

    steps   = parameters.steps;
    samples = parameters.samples;

    policy       = kla_mem(domain, reward);
    trajectories = trajectories_from_simulations(policy, t_b, s_1, samples, steps);
end