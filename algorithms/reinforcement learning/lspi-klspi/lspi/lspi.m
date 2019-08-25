% A wrapper that conforms LSPI to the RL interface
function [policy, time, policies, times] = lspi(domain, reward)

    clear([domain '_value_basis_lspi']);
    clear([domain '_simulator']);

    param_func = [domain '_parameters'];
    basis_func = [domain '_value_basis_lspi'];
    polic_func = [domain '_initialize_policy'];

    params = feval(param_func);
    basis  = feval(basis_func);

    max_iter  = params.N;
    max_epis  = params.M;
    max_steps = params.T;
    epsilon   = params.epsilon;
    resample  = params.resample;

    discount  = params.gamma;

    eval_alg = @lsq_spd;
    policy   = feval(polic_func, struct('explore',1, 'discount',discount, 'reward',reward, 'basis',basis));

    [~, all_policies] = lspi_klspi_core(domain, eval_alg, policy, max_iter, max_epis, max_steps, epsilon, resample);

    policy = @(s) policy_function(all_policies{end}, s);
    time   = all_policies{end}.time;

    policies = cellfun(@(p) {@(s) policy_function(p, s)}, all_policies);
    times    = cell2mat(cellfun(@(p) { p.time }, all_policies));
end