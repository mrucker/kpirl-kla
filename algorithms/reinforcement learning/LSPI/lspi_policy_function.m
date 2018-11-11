function [action, actionphi] = lspi_policy_function(policy, state)

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
% [action, actionphi] = policy_function(policy, state)
%
% Computes the "policy" at the given "state".
%
% Returns the "action" that the policy picks at that "state" and the
% evaluation ("actionphi") of the basis at the pair (state, action).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  valid_actions = policy.actions(state);

  %%% Exploration or not? 
  if (rand < policy.explore)
    
    %%% Pick one action in random
    action    = valid_actions(:,randi(size(valid_actions,2)));
    actionphi = feval(policy.basis, state, action);
    
  else
    
    %%% Pick the action with maximum Q-value
    bestq = -inf;
    besta = [];
    
    %%% Find first all actions with maximum Q-value
    
    phis = feval(policy.basis, state, valid_actions);
    qs   = phis' * policy.weights;
    
    maxq = max(qs);
    
    besta     = find(qs == maxq);
    actionphi = phis(:,qs == maxq);
    
%     for a=1:policy.actions
%       
%       phi = feval(policy.basis, state, a);
%       q = phi' * policy.weights;
%       
%       if (q > bestq)
%         bestq = q;
%         besta = [a];
%         actionphi = [phi];
%       elseif (q == bestq)
%         besta = [besta; a];
%         actionphi = [actionphi, phi];
%       end
%       
%     end
    
    %%% Now, pick one of them
    which = 1;                         % Pick the first (deterministic)
    %which = randint(length(besta));    % Pick randomly
    
    action    = valid_actions(:,besta(which));
    actionphi = actionphi(:,which);
    
  end
  
  
  return
