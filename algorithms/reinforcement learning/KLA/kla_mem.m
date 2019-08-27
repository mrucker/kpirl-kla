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
            explore = get_explore_function(parameters, Z);

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
                    
                    if isfield(parameters,'bootstrap') && parameters.bootstrap
                        y = t_r(w) + gamma*v_f(t_m{m}{w+1});
                    else
                        y = g_mat(w,:) * t_r';
                    end

                    if isKey(Z,i)

                        z = Z(i);
                        [k, Y, beta, var, alpha, eta, lambda] = deal(z(1),z(2),z(3),z(4),z(6),z(7),z(8));

                        %these step size calculations taken from Pg. 446-447 in
                        %Approximate Dynamic Programming by Powell in 2011
                        epsilon = Y - y;

                        if(epsilon == 0 && k > 2)
                            %for some reason I keep getting 0 error in my
                            %estimate, even after four iterations. This in turn
                            %causes my estimate of my estimator's bias (b)
                            %and the estimate of its variance (v) to become
                            %zero in some cases making my stepsize (a) NaN.
                            %to combat this I'll add a small perturbation
                            %with zero mean. That way the bias will be
                            %small but still existant
                            epsilon = 1/2*(rand-1/2);
                        end

                        beta   = (1-eta)*beta + eta*(epsilon);
                        var    = (1-eta)*var  + eta*(epsilon^2);
                        sig_sq = (var - beta^2)/(1+lambda);

                        if(k > 2)
                            BAKF_state = [epsilon, beta, var, sig_sq, sig_sq/var];
                            assert( ~( (sig_sq/var) > 10000 || any(isnan(BAKF_state)) || any(isinf(BAKF_state)) ) )
                        end

                        lambda = lambda*(1-alpha)^2 + alpha^2;
                        Y      = (1-alpha)*Y + alpha*y;

                        if (k < 3)
                            alpha = 1/(k+1);
                        else
                            alpha = 1 - (sig_sq/var);
                        end

                        if(k == 1)
                            eta = 1;
                        else
                            eta = eta/(.95+eta);
                        end

                        assert(~( any(1.0001 < [alpha,eta]) || any(isnan([alpha, eta, lambda])) || any(isinf([alpha, eta, lambda]))));

                        Z(i) = [k+1, Y, beta, var, sig_sq, alpha, eta, lambda];
                    else
                        %this is the "initialization" step from the algorithm; we don't use many of these for a few iterations.
                              %[k, Y, beta, var, sig_sq, alpha, eta, lambda]
                        Z(i) = [1, y,    0,   0,      0,     1,   1,      0];
                        X(i) = v_p(t_m{m}{w})';
                    end
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

function f = get_explore_function(parameters, Z)

    if isfield(parameters,'explore')
        explore_type = parameters.explore;
    else
        explore_type = 1;
    end

    GT = cellfun(@(z) z(1)>=3        , values(Z));
    SE = cellfun(@(z) sqrt(z(8)*z(5)), values(Z));
    BI = cellfun(@(z) z(3)           , values(Z));

    max_SE = max (SE(GT));
    avg_BI = mean(BI(GT));

    function c = zero_explore(~)
        c = 0;
    end

    function c = standard_explore(i)
        if ~iscell(i)
            i = num2cell(i');
        end

        is_key = isKey(Z,i);
        keys   = i(is_key);

        z = zeros(numel(i),8);
        z(is_key,:) = cell2mat(values(Z, keys));

        enough_visits_for_confidence = (z(:,1) >=3);

        c = (enough_visits_for_confidence .* sqrt(z(:,8).*z(:,5)) + ~enough_visits_for_confidence * (avg_BI + 2 * max_SE))'; 
    end

    if (explore_type == 0 || ~any(GT))
        f = @zero_explore;
    else 
        f = @standard_explore;
    end
end