function [policy, all_policies] = lspi_klspi_core(domain, algorithm, policy, max_iter, max_epis, max_steps, epsilon, resample)

    iteration = 0;
    distance  = inf;
    time      = 0;

    old_policy = policy;

    %%% policy iteration loop
    while ( (iteration < max_iter) && (distance > epsilon) )

        i_start = tic;

        if ~exist('samples', 'var') || resample
            samples = samples_from_episodes(domain, max_epis, max_steps, old_policy);
        end

        %%% Update and print the number of iterations
        iteration = iteration + 1;

        %%% Here you are allowed to make an changes you want to the new policy
        %%% For example, we could change the discount, basis or action fields
        new_policy = old_policy;

        %%% Evaluate the current policy (and implicitly improve)
        %%% There are several options here - choose one    
        new_policy = algorithm(samples, old_policy, new_policy);

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