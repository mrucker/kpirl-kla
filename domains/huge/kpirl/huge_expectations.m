function expectation = huge_expectations(reward)

    domain = 'huge';

    [r_i, r_p     ] = feval([domain '_reward_basii']);
    [  ~,   ~, t_b] = feval([domain '_transitions']);
    [s_1          ] = feval([domain '_random']);
    [paramaters   ] = feval([domain '_paramaters']);

    r_n = size(r_p, 2);
    r_e = @(s) double((1:r_n)' == r_i(s));

    steps   = paramaters.steps;
    samples = paramaters.samples;
    gamma   = paramaters.gamma;

    policy      = lspi(domain, reward);
    expectation = expectation_from_simulations(policy, t_b, s_1, r_e, steps, samples, gamma);
end