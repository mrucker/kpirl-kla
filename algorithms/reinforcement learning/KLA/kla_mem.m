function [policy, time, policies, times] = kla_mem(domain, reward)

    indexable_store = @(fill) indexable_mem(fill);
    indexable_func  = @(func) indexable_mem(func);

    [policy, time, policies, times] = kla_core(domain, reward, indexable_store, indexable_func);
end