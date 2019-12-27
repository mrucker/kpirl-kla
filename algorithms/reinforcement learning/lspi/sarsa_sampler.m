function sampler = sarsa_sampler(simulator, policy, max_epis, max_steps, resample)

    if resample
        sampler = @(new_policy) samples_from_simulations(simulator, new_policy, max_epis, max_steps);
    else
        samples = samples_from_simulations(simulator, policy, max_epis, max_steps);
        sampler = @(new_policy) samples_from_samples(samples, new_policy);
    end

end

function samples = samples_from_samples(samples, policy)
    for i = 1:numel(samples)

        [nextaction, nextfeats] = policy.function(samples(i).nextstate);

        samples(i).nextaction = nextaction;
        samples(i).nextfeats  = nextfeats;

    end
end

function samples = samples_from_simulations(simulator, policy, n_episodes, n_steps)

    samples = cell(1,n_episodes);
    
    parfor e = 1:n_episodes
        
        samp = {};
        step = 0;
        stop = 0;

        [s   ] = feval(simulator);
        [a, f] = policy.function(s);

        while ((step < n_steps) && (~stop))

            step = step + 1;

            samp{step}.state  = s;
            samp{step}.action = a;
            samp{step}.feats  = f;

            [s, stop] = feval(simulator, s, a);
            [a, f   ] = policy.function(s);
            [r      ] = policy.reward(s);

            samp{step}.reward     = r;
            samp{step}.nextstate  = s;
            samp{step}.nextaction = a;
            samp{step}.nextfeats  = f;
            samp{step}.absorb     = stop;
        end

        samples{e} = samp;
    end

    samples = cell2mat(horzcat(samples{:}));

end