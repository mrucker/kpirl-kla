function f = random_linear_reward(domain, count, rand_w)

    [s2f         ] = feval([domain '_features'], 'reward');
    [edges, parts] = feval([domain '_discrete'], 'reward');
    [r_p, ~      ] = discretes(s2f, edges, parts);

    if(nargin < 2)
        count = 1;
    end
    
    if(nargin < 3)
        rand_w = @(n) 1 - 2 * rand(1,n);
    end

    f = cell(1,count);

    for i = 1:count
        r_w = rand_w(r_p());
        
        f{i} = @(s) r_w * r_p(s);
    end
end