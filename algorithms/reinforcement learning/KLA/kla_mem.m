function [policy, time, policies, times] = kla_mem(domain, reward)

    gcp; %this is here to force the parallel pool to begin before we start timing

    start = tic;
        [v_i, v_p  ] = feval([domain '_value_basis']);    
        [s_1       ] = feval([domain '_random']);
        [a_f       ] = feval([domain '_actions']);
        [t_d, t_s  ] = feval([domain '_transitions']);
        [parameters] = feval([domain '_parameters']);

        N     = parameters.N;
        M     = parameters.M;
        T     = parameters.T;
        W     = parameters.W;
        gamma = parameters.gamma;

        explore_type = get_or_default(parameters, 'explore', 1);
        target_type  = get_or_default(parameters, 'target' , 0);
        smooth_type  = get_or_default(parameters, 'smooth' , 1);

        time     = zeros(5,1);
        policies = cell(1,N);
        times    = zeros(5,N);

        v_f = @(s) 3*ones(1,size(s,2)); %arbitrarily initialize all state values to 3

        g_mat = cell2mat(arrayfun(@(w) { [zeros(1,w) gamma.^(0:T-1) zeros(1,W-w)] }, 0:W)');

        Z = containers.Map('KeyType','double','ValueType','any');
        X = containers.Map('KeyType','double','ValueType','any');

    time(1) = toc(start);

    policies{1} = @(s) best_action_from_state(s, a_f(s), t_d, v_f);
    times(:,1)  = zeros(5,1);

    for n = 2:N

        start = tic;
            init_s  = arrayfun(@(m) { s_1() }, 1:M);
            explore = get_explore_function(explore_type, Z);

            t_m = repmat({cell(1,T+W)}, 1,M);
        time(2) = time(2) + toc(start);

        start = tic;
            parfor m = 1:M

                s_t = init_s{m};

                for t = 1:T+W

                    post_s_as = t_d(s_t, a_f(s_t));
                    post_v_vs = v_f(post_s_as);

                    if(t == 1)
                        post_v_vs = post_v_vs + explore(v_i(post_s_as));
                    end
                    
                    a_i = find(post_v_vs == max(post_v_vs));
                    a_i = a_i(randi(numel(a_i)));

                    t_m{m}{t} = post_s_as(:,a_i);
                    s_t       = t_s(t_m{m}{t});
                end
            end
        time(3) = time(3) + toc(start);

        start = tic;
            for m = 1:M
                t_r = reward(t_s(t_m{m}));
                for w = 1:W+1
                    i = v_i(t_m{m}{w});

                    if target_type == 1
                        y = t_r(w) + gamma*v_f(t_m{m}{w+1});
                    else
                        y = g_mat(w,:) * t_r';
                    end

                    if ~isKey(Z,i)
                        Z(i) = zeros(1,7);
                        X(i) = v_p(t_m{m}{w})';
                    end

                    z = Z(i);
                    [c, Y, beta, delta, nu, lambda] = deal(z(1),z(2),z(3),z(4),z(6),z(7));

                    %these step size calculations taken from Pg. 446-447 in
                    %Approximate Dynamic Programming by Powell in 2011 and
                    %Adaptive stepsizes for recursive estimation with applications 
                    %in approximate dynamic programming (2006)

                    c = c + 1;

                    if (c == 1 || c == 2)
                        nu = 1;
                    else
                        nu = nu/(.95+nu);
                    end

                    beta   = (1-nu)*beta + nu*(Y - y);
                    delta  = (1-nu)*delta + nu*(Y - y)^2;
                    var    = (delta - beta^2)/(1+lambda);

                    if (c == 1 || c == 2 || c == 3 || delta == 0 || smooth_type == 0)
                        alpha = 1/c;
                    else
                        alpha = 1 - (var/delta);
                    end

                    Y      = (1-alpha)*Y + alpha*y;
                    lambda = lambda*(1-alpha)^2 + alpha^2;

                    assert(~any([alpha, nu, lambda] > 1));
                    assert(~any(isnan([beta, delta, var, alpha, nu, lambda])));
                    assert(~any(isinf([beta, delta, var, alpha, nu, lambda])))

                    Z(i) = [c, Y, beta, delta, var, nu, lambda];
                end
            end
        time(4) = time(4) + toc(start);

        start = tic;

            x = cell2mat(values(X)');
            y = cellfun(@(z) z(2), values(Z))';

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(y)/1.349;
            end

            v_m = fitrsvm(x, y, 'KernelFunction','rbf', 'BoxConstraint', box_constraint, 'Solver', 'SMO', 'Standardize',true);
            v_f = @(s) predict(v_m, v_p(s)')';

        time(5) = time(5) + toc(start);

        policies{n} = @(s) best_action_from_state(s, a_f(s), t_d, v_f);
        times(:,n)  = time;
    end

    policy = policies{end};
    time   = times(:,end);
end

function f = get_explore_function(explore_type, Z)

    GT = cellfun(@(z) z(1)>=3        , values(Z));
    SE = cellfun(@(z) sqrt(z(7)*z(5)), values(Z));
    BI = cellfun(@(z) z(3)           , values(Z));

    max_SE = max (SE(GT));
    avg_BI = mean(BI(GT));

    function u = zero_explore(i)
        u = zeros(size(i));
    end

    function u = standard_explore(i)
        if ~iscell(i)
            i = num2cell(i');
        end

        is_key = isKey(Z,i);
        keys   = i(is_key);

        z = zeros(numel(i),7);
        z(is_key,:) = cell2mat(values(Z, keys));

        enough_visits_for_confidence = (z(:,1) >=3);

        u = (enough_visits_for_confidence .* sqrt(z(:,7).*z(:,5)) + ~enough_visits_for_confidence * (-avg_BI + 2 * max_SE))'; 
    end

    function u = random_explore(i)
        u = 100*rand(size(i));
    end

    if explore_type == 0 || ~any(GT)
        f = @zero_explore;
    elseif explore_type == 1
        f = @standard_explore;
    elseif explore_type == 2
        f = @random_explore;
    end
end