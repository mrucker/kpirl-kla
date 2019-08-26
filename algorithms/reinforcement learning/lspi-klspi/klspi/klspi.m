% A wrapper that conforms KLSPI to the RL interface
function [policy, time, policies, times] = klspi(domain, reward)

    polic_func = [domain '_policy'];
    simul_func = [domain '_simulator'];
    param_func = [domain '_parameters'];
    basis_func = [domain '_value_basis_klspi'];
    
    clear(basis_func);
    clear(simul_func);
    
    [policy      ] = feval(polic_func);
    [params      ] = feval(param_func);
    [basis, affin] = feval(basis_func);
    
    max_iter  = params.N;
    max_epis  = params.M;
    max_steps = params.T;
    epsilon   = params.epsilon;
    resample  = params.resample;
    mu        = params.mu;

    policy.reward   = reward;
    policy.basis    = basis;
    policy.affin    = affin;
 
    sampler  = sarsa_sampler(simul_func, policy, max_epis, max_steps, resample);
    eval_alg = @(samples, policy, new_policy) klsq_spd(samples, policy, new_policy, mu);

    [~, all_policies] = lspi_klspi_core(sampler, eval_alg, policy, max_iter, epsilon);

    policy = @(s) policy_function(all_policies{end}, s);
    time   = all_policies{end}.time;

    policies = cellfun(@(p) {@(s) policy_function(p, s)}, all_policies);
    times    = cell2mat(cellfun(@(p) { p.time }, all_policies));
end