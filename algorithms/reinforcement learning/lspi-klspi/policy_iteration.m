function [policy, all_policies] = policy_iteration(domain, algorithm, policy, max_iter, max_epis, max_steps, epsilon)

  clear lsq_spd
  clear lsqbe_spd

  all_policies{1} = policy;
  
  iteration = 0;
  distance = inf;
    
  samples = samples_from_episodes(domain, max_epis, max_steps, policy);
  
  %%% Main LSPI loop  
  while ( (iteration < max_iter) && (distance > epsilon) )
      
    i_start = tic;
      
    %%% Update and print the number of iterations
    iteration = iteration + 1;

    %%% You can optionally make a call to collect_samples right here
    %%% to change/update the sample set. Make sure firsttime is set
    %%% to 1 if you do so.

    %%% Evaluate the current policy (and implicitly improve)
    %%% There are several options here - choose one    
    policy = algorithm(samples, all_policies{iteration}, policy);
    
    %%% Compute the distance between the current and the previous policy
    if(~isfield(all_policies{iteration}, 'weights'))
      distance = inf;  
    elseif (length(policy.weights) == length(all_policies{iteration}.weights))
      distance = norm(policy.weights - all_policies{iteration}.weights);
    else
      distance = abs(norm(policy.weights) - norm(all_policies{iteration}.weights));
    end
    
    %%% Store the current policy
    all_policies{iteration+1}      = policy;
    all_policies{iteration+1}.time = toc(i_start);

  end
  
  return
