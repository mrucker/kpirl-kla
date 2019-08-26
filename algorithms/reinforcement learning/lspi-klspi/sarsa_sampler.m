function sampler = sarsa_sampler(simulator, policy, max_epis, max_steps, resample)

    if resample
        sampler = @(new_policy) samples_from_simulation(simulator, new_policy, max_epis, max_steps);
    else
        samples = samples_from_simulation(simulator, policy, max_epis, max_steps);
        sampler = @(new_policy) samples_from_samples(samples, new_policy);
    end

end

function samples = samples_from_samples(samples, policy)

end

function samples = samples_from_simulation(simulator, policy, n_episodes, n_steps)

    episode_samples = cell(1,n_episodes);
    
    for e = 1:n_episodes
        episode_samples{e} = create_episode_samples(simulator, policy, n_steps);
    end

    samples = cell2mat(episode_samples);

end

function episode_samples = create_episode_samples(simulator, policy, max_steps)  

    episode_samples = repmat(struct(), 1, max_steps);

    steps  = 0;
    endsim = 0;

    state = feval(simulator);
    
    while ( (steps < max_steps) && (~endsim) )

        steps = steps + 1;

        action              = policy_function(policy, state);
        [nextstate, endsim] = feval(simulator, state, action);

        episode_samples(steps).state     = state;
        episode_samples(steps).action    = action;
        episode_samples(steps).reward    = policy.reward(state);
        episode_samples(steps).nextstate = nextstate;
        episode_samples(steps).absorb    = endsim;

        state = nextstate;

    end

    episode_samples = episode_samples(1:steps);

end