function new_policy = lsq_mem(samples, policy, new_policy)

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
% new_policy = lsq_mem(samples, policy, new_policy)
%
% Evaluates the "policy" using the set of "samples", that is, it
% learns a set of weights for the basis specified in new_policy to
% form the approximate Q-value of the "policy" and the improved
% "new_policy". The approximation is the fixed point of the Bellman
% equation.
%
% Returns the new policy with weights set to w of Aw=b. 
%
% See also lsq_spd.m for a faster (batch) implementation. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%% Initialize variables
  howmany = length(samples);
  k       = feval(new_policy.basis);
  A       = zeros(k, k);
  b       = zeros(k, 1);  

  %%% Loop through the samples 
  for i=1:howmany

    %%% Compute the basis for the current state and action
    phi = feval(new_policy.basis, samples(i).state, samples(i).action);

    %%% Make sure the nextstate is not an absorbing state
    if ~samples(i).absorb
      %%% Compute the policy and the corresponding basis at the next state 
      nextaction = policy_function(policy, samples(i).nextstate);
      nextphi    = feval(new_policy.basis, samples(i).nextstate, nextaction);
    else
      nextphi = zeros(k, 1);
    end

    %%% Update the matrices A and b
    A = A + phi * (phi - new_policy.discount * nextphi)';
    b = b + phi * samples(i).reward;

  end

  if rank(A)==k
    w = A\b;
  else
    w = pinv(A)*b;
  end

  new_policy.weights = w;
  
  return
  
