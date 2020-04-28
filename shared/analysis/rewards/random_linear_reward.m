function f = random_linear_reward(domain, count, rand_w)

    [s2f         ] = feval([domain '_features'], 'reward');
    [edges, parts] = feval([domain '_discrete'], 'reward');
    
    [f2i, i2d    ] = discrete(edges, parts);
    [s2i         ] = @(s) f2i(s2f(s));

    if(nargin < 2)
        count = 1;
    end
    
    if(nargin < 3)
        rand_w = @(n) 1 - 2 * rand(1,n);
    end

    f = cell(1,count);

    for i = 1:count
        r_w = rand_w(size(i2d(1),1));

        f{i} = @(s) r_w * i2d(s2i(s));
    end
end