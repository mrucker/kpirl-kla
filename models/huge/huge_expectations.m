function expectation = huge_expectations(reward)

    [r_p, r_i     ] = huge_reward_basii();
    [  ~,   ~, t_b] = huge_transitions();    
    [s_1          ] = huge_random();
    [paramaters   ] = huge_paramaters();

    r_e = @(s) index_vector_from_index_perms(r_i(s), r_p);
    
    steps   = paramaters.steps;
    samples = paramaters.samples;
    gamma   = paramaters.gamma;

    policy      = kla(domain, reward);
    expectation = @(r) expectation_from_simulations(policy, t_b, s_1, r_e, steps, samples, gamma);
end