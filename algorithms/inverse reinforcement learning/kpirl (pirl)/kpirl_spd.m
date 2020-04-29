function [reward_function, time_measurements] = kpirl_spd(domain)

    [edges, parts] = feval([domain '_discrete'], 'reward');
    f2i = discrete(edges, parts);
    
    n_col = numel(f2i());

    indexable_func  = @(func) indexable_spd(func(1:n_col), 1:n_col);

    [reward_function, time_measurements] = kpirl_core(domain, indexable_func);
end