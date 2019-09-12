function [policy, time, policies, times] = kla_spd(domain, reward)

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

        is_exp  = ~isfield(parameters,'explore') || parameters.explore;
        is_OSA  = ~isfield(parameters,'OSA') || parameters.OSA;
        is_boot =  isfield(parameters,'bootstrap') && parameters.bootstrap;

        time     = zeros(5,1);
        policies = cell(1,N);
        times    = zeros(5,N);

        v_f = @(s) 3*ones(1,size(s,2)); %arbitrarily initialize all state values to 3

        g_mat = cell2mat(arrayfun(@(w) { [zeros(1,w) gamma.^(0:T-1) zeros(1,W-w)] }, 0:W)');

        v_n = v_i();
        v_p = v_p(1:v_n);

        Z = zeros(v_n, 7);
    time(1) = toc(start);

    policies{1} = @(s) best_action_from_state(s, a_f(s), t_d, v_f);
    times(:,1)  = zeros(5,1);

    for n = 2:N

        start = tic;
            init_s  = arrayfun(@(m) { s_1() }, 1:M);    
            explore = get_explore_function(is_exp, Z);

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

                    if is_boot
                        y = t_r(w) + gamma*v_f(t_m{m}{w+1});
                    else
                        y = g_mat(w,:) * t_r';
                    end

                    z = Z(i,:);
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

                    beta  = (1-nu)*beta + nu*(Y - y);
                    delta = (1-nu)*delta + nu*(Y - y)^2;
                    var   = (delta - beta^2)/(1+lambda);

                    if (c == 1 || c == 2 || c == 3 || delta == 0 || ~is_OSA)
                        alpha = 1/c;
                    else
                        alpha = 1 - (var/delta);
                    end

                    Y      = (1-alpha)*Y + alpha*y;
                    lambda = lambda*(1-alpha)^2 + alpha^2;

                    assert(~any([alpha, nu, lambda] > 1));
                    assert(~any(isnan([beta, delta, var, alpha, nu, lambda])));
                    assert(~any(isinf([beta, delta, var, alpha, nu, lambda])))

                    Z(i,:) = [c, Y, beta, delta, var, nu, lambda];
                end
            end
        time(4) = time(4) + toc(start);

        start = tic;

            x = v_p(:, Z(:,1) > 0);
            y =   Z(Z(:,1) > 0, 2);

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(y)/1.349;
            end

            v_m = fitrsvm(x',y','KernelFunction','rbf', 'BoxConstraint', box_constraint, 'Solver', 'SMO', 'Standardize',true);
            v_v = predict(v_m, v_p')';
            v_f = @(s) v_v(v_i(s));

        time(5) = time(5) + toc(start);

        policies{n} = @(s) best_action_from_state(s, a_f(s), t_d, v_f);
        times(:,n)  = time;
    end

    policy = policies{end};
    time   = times(:,end);
end

function f = get_explore_function(is_exp, Z)

    C = Z(:,1)';

    if ~is_exp || all(C<3)
        U = zeros(1, size(Z,1));
    else
        SE = sqrt(Z(:,7).*Z(:,5))';
        BI = -Z(:,3)';
        U  = BI + 2*SE;

        %U(C<3) = prctile(U(C>=3), 95);
        U(C<3) = mean(BI) + 2*max(SE);
    end

    f = @(v_is) U(v_is);
end