% A wrapper that conforms KLSPI to the RL interface
% The original klspi function is now called kslpi_core
function [policy, time] = lspi(domain, reward); global R;

    a_start = tic;

        R = reward;

        clear [domain '_value_basis_lspi'];
        clear [domain '_simulator'];

        [parameters] = feval([domain '_parameters']);
        [t_d       ] = feval([domain '_transitions']);

        maxiter     = parameters.N;
        epsilon     = parameters.epsilon;
        maxepisodes = parameters.M;
        maxsteps    = parameters.T;
        discount    = parameters.gamma;
        basis       = [domain '_value_basis_lspi'];
        eval_alg    = 2;% 1->lsq; 2->lsqfast; 3->lsqbe; 4->lsqbefast;

        policy = feval([domain '_initialize_policy'], 0.0, discount, basis);

        samples = collect_samples(domain, maxepisodes, maxsteps);
        %samples = collect_samples(domain, maxepisodes, maxsteps, policy);

        [~, all_policies] = lspi_core(domain, eval_alg, maxiter, epsilon, samples, basis, discount, policy);

        last_policy = all_policies{end};

        v_p    = feval(basis, []);
        v_v    = v_p'*last_policy.weights;
        v_i    = @(s) feval(basis, s);
        values = @(s) v_v(v_i(s));
        policy = @(s) best_action_from_state(s, last_policy.actions(s), t_d, values);

    time = toc(a_start);
end