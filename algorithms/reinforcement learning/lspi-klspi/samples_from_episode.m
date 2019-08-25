function [new_results, totdrew, toturew] = samples_from_episode(initial_state, simulator, policy, n_steps)

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
% [new_results, totdrew, toturew] = samples_from_episode(initial_state, 
%                                           simulator, policy, maxsteps)
%
% Executes one episode (of at most "maxsteps" steps) on the
% "simulator" starting at the "initial_state" and using the "policy"
% to select actions.
%
% Returns all the samples collected during the episode and the total
% discounted and undiscounted reward.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%% Initialize storage for new samples 
  empty_result.state = feval(simulator);
  empty_result.action = 0;
  empty_result.reward = 0.0;
  empty_result.nextstate = empty_result.state;
  empty_result.absorb = 0;
  
  results = repmat(empty_result, 1, n_steps);
  
  %%% Initialize variables
  totdrew = 0;
  toturew = 0;
  steps = 0;
  endsim = 0;
  
  %%% Set initial state
  state = initial_state;
  
  %%% Run the episode
  while ( (steps < n_steps) && (~endsim) )

    steps = steps + 1;

    %%% Select action 
    action = policy_function(policy, state);

    %%% Simulate
    [nextstate, endsim] = feval(simulator, state, action);
    
    %%% Record sample
    results(steps).state     = state;
    results(steps).action    = action;
    results(steps).reward    = policy.reward(state);
    results(steps).nextstate = nextstate;
    results(steps).absorb    = endsim;
    
    %%% Update the total reward(s)
    totdrew = totdrew + (policy.discount)^(steps-1) * results(steps).reward;
    toturew = toturew + results(steps).reward;

    %%% Continue
    state = nextstate;
    
  end
  
  
  %%% Return the results
  new_results = results(1:steps);
  
  
  return
  
