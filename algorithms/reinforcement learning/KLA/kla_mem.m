function [policy, time, policies, times] = kla_mem(domain, reward)
    [policy, time, policies, times] = kla_core(domain, reward, @mem);
end