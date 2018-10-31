%Be careful, if states is too big, realizing the whole policy may overload memory.
%Also, this assumes that reward is not dependent on action. If it is this won't work.
function Pf = policy_function(Af, Vf, trans)
    Pf = @(s) col_i(Af(s), max_i(Vf(trans(s, Af(s)))));
end

function a = col_i(matrix, i)
    a = matrix(:,i);
end

function i = max_i(values)
    [~, i] = max(values);
end