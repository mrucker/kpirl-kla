function [reward_function, time_measurements] = kpirl_mem(domain)

    indexable_func  = @(func) indexable_mem(func);

    [reward_function, time_measurements] = kpirl_core(domain, indexable_func);
end