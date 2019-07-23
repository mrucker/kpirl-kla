function new_policy = lsq_spd(samples, policy, new_policy)

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
% new_policy = lsq_spd(samples, policy, new_policy)
%
% Evaluates the "policy" using the set of "samples", that is, it
% learns a set of weights for the basis specified in new_policy to
% form the approximate Q-value of the "policy" and the improved
% "new_policy". The approximation is the fixed point of the Bellman
% equation.
%
% Returns the new policy with weights set to w of Aw=b.
%
% NOTE: this function can be made nearly twice as fast by caching
%       the features from the state/action pairs when not resampling
%
% See also lsq_mem.m for a slower (incremental) implementation. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%% Initialize variables
  howmany  = length(samples);
  k        = feval(new_policy.basis);
  Rhat     = zeros(howmany,1);
  Phihat   = zeros(howmany,k);
  PiPhihat = zeros(howmany,k);

  basis_function = new_policy.basis;

  %%% Loop through the samples 
  for i=1:howmany

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
  A = Phihat' * (Phihat - new_policy.discount * PiPhihat);
  b = Phihat' * Rhat;

  if rank(A) == k
    w = A\b;
  else
    w = pinv(A)*b;
  end

  new_policy.weights = w;

  return
