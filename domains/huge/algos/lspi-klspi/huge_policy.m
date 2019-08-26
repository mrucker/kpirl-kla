function policy = huge_policy()

    params = huge_parameters();

    policy.explore  = 1;
    policy.discount = params.gamma;
    policy.actions  = huge_actions();
end