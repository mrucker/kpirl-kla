function [policy, time, policies, times] = kla_spd(domain, reward)
    [policy, time, policies, times] = kla_core(domain, reward, @spd);
end