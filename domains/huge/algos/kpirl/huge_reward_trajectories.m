function trajectories = huge_reward_trajectories(reward)

    domain = 'huge';

    [  ~,   ~, t_b] = feval([domain '_transitions']);
    [s_1          ] = feval([domain '_random']);
    [parameters   ] = feval([domain '_parameters']);

    samples = parameters.samples;
    steps   = parameters.steps;

    policy       = kla(domain, reward);
    trajectories = trajectories_from_simulations(policy, t_b, s_1, samples, steps);
end