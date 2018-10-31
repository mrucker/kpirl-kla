%Technically this can also be passed back by the value iteration algorithm.
%However, to provide symmetry with the approx algorithms I add it here too.
function P = policy_vector_pre(states, actions, pre_Vf, pre_pdf)
    S_N = size(states,2);
    A_N = size(actions,2);
    
    Q = zeros(S_N, A_N);
    
    for a_i = 1:A_N
        Q(:, a_i) = pre_pdf{a_i}*pre_Vf;
    end
    
    [~, P] = max(Q, [], 2);
end