function new_policy = lsqbe_spd(samples, policy, new_policy)
  
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
% See also lsqbe_mem.m for slower (incremental) implementation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  persistent Phihat;
  persistent Rhat;  
  
  %%% Initialize variables
  howmany = length(samples);
  k = feval(new_policy.basis);
  PiPhihat = zeros(howmany,k);
  
  %%% Precompute Phihat and Rhat for all subsequent iterations
  if isempty(Phihat) || isempty(Rhat)

    Phihat = zeros(howmany,k);
    Rhat = zeros(howmany,1);

    for i=1:howmany
      phi = feval(new_policy.basis, samples(i).state, samples(i).action);
      Phihat(i,:) = phi';
      Rhat(i) = samples(i).reward;
    end

  end
  
  
  %%% Loop through the samples 
  for i=1:howmany
    
    %%% Make sure the nextstate is not an absorbing state
    if ~samples(i).absorb
      
      %%% Compute the policy and the corresponding basis at the next state 
      nextaction = policy_function(policy, samples(i).nextstate);
      nextphi = feval(new_policy.basis, samples(i).nextstate, nextaction);
      PiPhihat(i,:) = nextphi';
      
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
  
  return
  
