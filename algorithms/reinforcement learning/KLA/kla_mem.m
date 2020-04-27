function [policy, time, policies, times] = kla_mem(domain, reward)
    [policy, time, policies, times] = kla_core(domain, reward, @Q_bar_ctor);
end

function f = Q_bar_ctor(predictor)
    assert(nargin == 0 || nargin == 1, 'incorrect inputs');

    if(nargin == 0)
        f = @(is) ones(1,numel(is));
    else
        f = @(is) predictor(is);
    end
end