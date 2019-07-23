function new_policy = lsqbe_spd(domain, samples, policy, new_policy)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2000-2002 
%
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University, NC 27708
%
%
% new_policy = lsqbefast(samples, policy, new_policy)
%
% Evaluates the "policy" using the set of "samples", that is, it
% learns a set of weights for the basis specified in new_policy to
% form the approximate Q-value of the "policy" and the improved
% "new_policy". The approximation minimizes the bellman error.
%
% Returns the new policy with weights set to w of Aw=b.
%
% NOTE: this function can be made nearly twice as fast by caching
%       the features from the state/action pairs when not resampling
%
% See also lsqbe_mem.m for slower (incremental) implementation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%% Initialize variables
  howmany  = length(samples);
  k        = feval(new_policy.basis);
  PiPhihat = zeros(howmany,k);
  Phihat   = zeros(howmany,k);
  Rhat     = zeros(howmany,1);

  basis_function = new_policy.basis;
  param_function = [domain '_parameters'];

  parameters = feval(param_function);

  %%% Loop through the samples 
  parfor i=1:howmany

    %because we're in a multi-thread environment we need to 
    %re-init our algorithm's parameters so we can use them here
    feval(param_function, parameters);
      
    Phihat(i,:) = feval(basis_function, samples(i).state, samples(i).action);
    Rhat(i)     = samples(i).reward;
    
    %%% Make sure the nextstate is not an absorbing state
    if ~samples(i).absorb
      %%% Compute the policy and the corresponding basis at the next state 
      nextaction    = policy_function(policy, samples(i).nextstate);
      PiPhihat(i,:) = feval(basis_function, samples(i).nextstate, nextaction);
    else
      PiPhihat(i,:) = zeros(1, k);
    end
    
  end
  
  
  %%% Compute the matrices A and b
  A = (Phihat - new_policy.discount * PiPhihat)' * (Phihat - new_policy.discount * PiPhihat);
  b = (Phihat - new_policy.discount * PiPhihat)' * Rhat;
  
  %%% Solve the system to find w
  if rank(A)==k
    w = A\b;
  else
    w = pinv(A)*b;
  end
  
  new_policy.weights = w;
  new_policy.explore = 0;
  
  return
  
