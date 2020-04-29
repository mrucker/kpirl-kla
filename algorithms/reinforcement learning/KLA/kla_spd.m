function [policy, time, policies, times] = kla_spd(domain, reward)

    [edges, parts] = feval([domain '_discrete'], 'value');
    f2i = discrete(edges, parts);
    
    n_col = numel(f2i());

    indexable_store = @(fill) indexable_spd(repmat(fill, 1, n_col));
    indexable_func  = @(func) indexable_spd(func(1:n_col), 1:n_col);

    [policy, time, policies, times] = kla_core(domain, reward, indexable_store, indexable_func);
    
end