% A wrapper that conforms KLSPI to the RL interface
function [policy, time, policies, times] = klspi(domain, reward)

    clear([domain '_value_basis_klspi']);
    clear([domain '_simulator']);

    polic_func = [domain '_policy'];
    param_func = [domain '_parameters'];
    basis_func = [domain '_value_basis_klspi'];

    [params      ] = feval(param_func);
    [basis, simil] = feval(basis_func);
    
    max_iter  = params.N;
    max_epis  = params.M;
    max_steps = params.T;
    epsilon   = params.epsilon;
    discount  = params.gamma;
    mu        = params.mu;
    resample  = params.resample;

    policy          = feval(polic_func);
    policy.explore  = 1;
    policy.discount = discount;
    policy.reward   = reward;
    policy.basis    = basis;
    policy.simil    = simil;
    
    eval_alg = @(samples, policy, new_policy) klsq_spd(samples, policy, new_policy, mu);

    [~, all_policies] = lspi_klspi_core(domain, eval_alg, policy, max_iter, max_epis, max_steps, epsilon, resample);

    policy = @(s) policy_function(all_policies{end}, s);
    time   = all_policies{end}.time;

    policies = cellfun(@(p) {@(s) policy_function(p, s)}, all_policies);
    times    = cell2mat(cellfun(@(p) { p.time }, all_policies));
end