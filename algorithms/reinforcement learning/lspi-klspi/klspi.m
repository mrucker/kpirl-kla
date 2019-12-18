% A wrapper that conforms KLSPI to the RL interface
function [policy, time, policies, times] = klspi(domain, reward)

    params       = feval([domain '_parameters']);
    params.basis = ald_basis(params.mu, params.kernel);

    feval([domain '_parameters'], params)

    [policy, time, policies, times] = lspi(domain, reward);    
end