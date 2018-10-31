function qvalue = Qvalue(state, action, policy, Dic, para)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4%para~=0
    phi = feval(policy.basis, state, action);
else
    phi = feval(policy.basis, state, action, Dic, para);
end
qvalue = phi' * policy.weights;
return
