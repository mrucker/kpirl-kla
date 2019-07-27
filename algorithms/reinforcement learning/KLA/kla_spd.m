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

        time     = zeros(5,1);
        policies = cell(1,N);
        times    = zeros(5,N);

        v_n = v_i();
        v_p = v_p(1:v_n);
        v_f = @(s) 3*ones(1,size(s,2)); %arbitrarily initialize all state values to 3

        g_mat = cell2mat(arrayfun(@(w) { [zeros(1,w) gamma.^(0:T-1) zeros(1,W-w)] }, 0:W)');

        Y = NaN  (1, v_n); %last  visitation value
        K = zeros(1, v_n); %total visitation count
        J = NaN  (1, v_n); %last  visitation iter

        %one for every value_basii updated for entire life of program (BAKF)
        epsilon = NaN(1, v_n);
        beta    = NaN(1, v_n);
        var     = NaN(1, v_n);
        sig_sq  = NaN(1, v_n);
        alpha   = NaN(1, v_n);
        eta     = NaN(1, v_n);
        lambda  = NaN(1, v_n);
    time(1) = toc(start);

    for n = 1:N

        start = tic;
            SE      = sqrt(lambda.*sig_sq);
            SE(K<3) = max([SE(K>=3),0]);

            BI      = beta;
            BI(K<3) = mean([BI(K>=3),0]);

            init_s  = arrayfun(@(m) { s_1() }, 1:M);

            t_m = repmat({cell(1,T+W)}, 1,M);
        time(2) = time(2) + toc(start);

        start = tic;
            parfor m = 1:M

                s_t = init_s{m};

                for t = 1:T+W

                    post_s_as = t_d(s_t, a_f(s_t));
                    post_v_vs = v_f(post_s_as);

                    if(t == 1)
                        post_v_is = v_i(post_s_as);
                        post_v_vs = post_v_vs + BI(post_v_is) + 2 * SE(post_v_is);
                    end

                    % rather than selecting a random action of highest value we just pick the first one
                    % experimentation on the "huge" domain suggeted there was no difference in performance
                    [~,a_i] = max(post_v_vs);

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
                    y = g_mat(w,:) * t_r';
                    k = K(i);

                    if ~isnan(Y(i))
                        %these step size calculations taken from Pg. 446-447 in
                        %Approximate Dynamic Programming by Powell in 2011
                        e = Y(i) - y;

                        if(e == 0 && k > 2)
                            %for some reason I keep getting 0 error in my
                            %estimate, even after four iterations. This in turn
                            %causes my estimate of my estimators bias (b)
                            %and the estimate of its variance (v) to become
                            %zero in some cases making my stepsize (a) NaN.
                            %to combat this I'll add a small perturbation
                            %with zero mean. That way the bias will be
                            %small but still existant
                            e = .5*(.5 - rand);
                        end

                        b = (1-eta(i))*beta(i) + eta(i)*(e  );
                        v = (1-eta(i))*var (i) + eta(i)*(e^2);
                        s = (v - b^2)/(1+lambda(i));

                        if(k > 2)
                            assert(~( (s/v) > 10000 || any(isnan([e, b, v, s, s/v])) || any(isinf([e, b, v, s, s/v])) ))
                        end

                        epsilon(i) = e;
                        beta   (i) = b;
                        var    (i) = v;
                        sig_sq (i) = s;

                        Y(i) = (1-alpha(i))*Y(i) + alpha(i)*y;
                        K(i) = k + 1;
                        J(i) = 1/3*J(i) + 2/3*n;

                        l = ((1-alpha(i))^2)*lambda(i) + alpha(i)^2;

                        if (k <= 2)
                            a = 1/(k+1);
                        else
                            a = 1 - (s/v);
                        end

                        if(k == 1)
                            e = 1;
                        else
                            e = eta(i)/(1+eta(i)-.05);
                        end

                        assert(~( any(1.0001 < [a,e]) || any(isnan([a, e, l])) || any(isinf([a, e, l]))));

                        alpha (i) = a;
                        eta   (i) = e;
                        lambda(i) = l;

                    else
                        Y(i) = y;
                        K(i) = 1;
                        J(i) = n;

                        %this is the "initialization" step from the algorithm
                        epsilon(i) = 0; % we don't use for a few iterations
                        beta   (i) = 0; % we don't use for a few iterations
                        var    (i) = 0; % we don't use for a few iterations
                        alpha  (i) = 1;
                        eta    (i) = 1;
                        lambda (i) = 0; % we don't use for a few iterations
                    end
                end
            end
        time(4) = time(4) + toc(start);

        start = tic;

            x = v_p(:, K > 0);
            y =   Y(   K > 0);
        
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