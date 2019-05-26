function expectation = rem_expectations(reward)

    domain = 'rem';

    [r_i, r_p     ] = feval([domain '_reward_basii']);
    [  ~,   ~, t_b] = feval([domain '_transitions']);
    [s_1          ] = feval([domain '_random']);
    [parameters   ] = feval([domain '_parameters']);

    r_n = size(r_p, 2);
    r_e = @(s) double((1:r_n)' == r_i(s));

    samples = parameters.samples;
    steps   = parameters.steps;
    gamma   = parameters.gamma;

    policy       = kla(domain, reward);
    trajectories = trajectories_from_simulations(policy, t_b, s_1, samples, steps); 
    expectation  = expectation_from_trajectories(trajectories, r_e, gamma);
end