% A wrapper that conforms LSPI to the RL interface
function [policy, time] = lspi(domain, reward); global R;

    a_start = tic;

        R = reward;

        clear([domain '_value_basis_lspi']);
        clear([domain '_simulator']);

        param_func = [domain '_parameters'];
        basis_func = [domain '_value_basis_lspi'];
        polic_func = [domain '_initialize_policy'];

        parameters = feval(param_func);

        max_iter  = parameters.N;
        max_epis  = parameters.M;
        max_steps = parameters.T;
        epsilon   = parameters.epsilon;
        basis     = basis_func;
        discount  = parameters.gamma;

        eval_alg = @lsq_spd;
        policy   = feval(polic_func, basis, discount);

        [~, all_policies] = policy_iteration(domain, eval_alg, policy, max_iter, max_epis, max_steps, epsilon);

        policy = @(s) policy_function(all_policies{end}, s);

    time = toc(a_start);
end