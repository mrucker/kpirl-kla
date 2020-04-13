% A wrapper that conforms LSPI to the RL interface
function [policy, time, policies, times] = lspi(domain, reward)

    actio_func = [domain '_actions'];
    param_func = [domain '_parameters'];
    trans_func = [domain '_transitions'];
    feats_func = [domain '_features'];

    [s2a    ] = feval(actio_func);
    [s2f    ] = feval(feats_func, 'value');
    [s2s,s2p] = feval(trans_func);
    [params ] = feval(param_func);

    max_iter  = params.N;
    max_epis  = params.M;
    max_steps = params.T;
    resample  = params.resample;
    epsilon   = 0;

    policy.explore  = 1;
    policy.actions  = s2a; 
    policy.reward   = reward;
    policy.discount = params.gamma;
    policy.feats    = @(s, as) s2f(s2p(s,as));
    policy.function = @(s) policy_function(policy, s);

    sampler  = sarsa_sampler(s2p, s2s, policy, max_epis, max_steps, resample);

    base_alg = get_or_default(params, 'basis' , ident_basis());
    eval_alg = @lsq_spd;

    [~, all_policies] = lspi_klspi_core(sampler, base_alg, eval_alg, policy, max_iter, epsilon);

    policy = all_policies{end}.function;
    time   = all_policies{end}.time;

    policies = cellfun(@(p) { p.function }, all_policies);
    times    = cell2mat(cellfun(@(p) { p.time }, all_policies));
end