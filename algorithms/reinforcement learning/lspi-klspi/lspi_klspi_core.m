function [policy, all_policies] = lspi_klspi_core(sampler, eval_alg, policy, max_iter, epsilon)

    iteration = 1;
    time      = 0;
    distance  = inf;

    all_policies{iteration}      = policy;
    all_policies{iteration}.time = time;

    old_policy = policy;

    while ( (iteration < max_iter) && (distance > epsilon) )

        i_start = tic;

        iteration = iteration + 1;
        samples = sampler(old_policy);

        %%% Here you are allowed to make an changes you want to the new policy
        %%% For example, we could change the discount, basis or action fields
        %%% Also this line works because everything is passed by value in MATLAB
        new_policy = old_policy;

        %%% Evaluate the current policy (and implicitly improve)
        %%% There are several options here - choose one    
        new_policy = eval_alg(samples, new_policy);

        %%% Compute the distance between the current and the previous policy
        if(~isfield(old_policy, 'weights') || ~isfield(new_policy, 'weights'))
            distance = inf;
        elseif (length(new_policy.weights) == length(old_policy.weights))
            distance = norm(new_policy.weights - old_policy.weights);
        else
            distance = abs(norm(new_policy.weights) - norm(old_policy.weights));
        end

        time = time + toc(i_start);

        %%% Store the current policy
        all_policies{iteration}      = new_policy;
        all_policies{iteration}.time = time;

        old_policy = new_policy;
    end
end