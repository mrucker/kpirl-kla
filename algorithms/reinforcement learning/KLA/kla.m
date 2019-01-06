function [policy, time] = kla(domain, reward)

    gcp; %this is here to force the parallel pool to begin before we start timing

    start = tic;
        [v_i, v_p  ] = feval([domain '_value_basii']);
        [s_1       ] = feval([domain '_random']);
        [a_v       ] = feval([domain '_actions']);
        [t_d, t_s  ] = feval([domain '_transitions']);
        [paramaters] = feval([domain '_paramaters']);

        N     = paramaters.N;
        M     = paramaters.M;
        T     = paramaters.T;
        W     = paramaters.W;
        gamma = paramaters.gamma;

        time = zeros(1,5);

        v_n = size(v_p,2);
        v_v = 3*ones(1,v_n); %arbitrarily initialize all state values to 3

        g_mat = cell2mat(arrayfun(@(w)circshift([gamma.^(0:T-1), zeros(1,W-1)],w-1), 1:W, 'UniformOutput',false)');

        %these variables manage the approximate "on-policy" sampling distribution
        init_recycle = 4;
        init_count   = 0;
        init_growth  = M*(T+W-1);
        init_states  = cell(init_growth*init_recycle,1);

        Y = NaN  (1, v_n); %last  visitation value
        K = zeros(1, v_n); %total visitation count
        J = NaN  (1, v_n); %last  visitation iter

        %one for every value_basii updated for entire life of program (BAKF)
        epsilon = NaN(1, v_n);
        beta    = NaN(1, v_n);
        nu      = NaN(1, v_n);
        sig_sq  = NaN(1, v_n);
        alpha   = NaN(1, v_n);
        eta     = NaN(1, v_n);
        lambda  = NaN(1, v_n);
    time(1) = toc(start);
    
    for n = 1:N

        start = tic;

            if mod(n,init_recycle) == 1
                init_states(init_count + (1:init_growth)) = arrayfun(@(m) s_1(), 1:init_growth, 'UniformOutput', false);
                init_count = init_count + init_growth;
            end

            init = init_states(randperm(init_count, M)); 

            X_b_m = arrayfun(@(i) zeros(1,T+W-1), 1:M, 'UniformOutput', false);
            X_s_m = arrayfun(@(i) cell (1,T+W-1), 1:M, 'UniformOutput', false);

            SE      = sqrt(sig_sq ./ K);
            SE(K<3) = max([SE(K>=3),0]);

            parfor m = 1:M

                s_t = init{m};

                for t = 1:T+W-1

                    post_s_as = t_d(s_t, a_v(s_t));
                    post_v_is = v_i(post_s_as);
                    post_v_vs = v_v(post_v_is);

                    if(t == 1)
                        post_v_vs = post_v_vs + 2 * SE(post_v_is);
                    end

                    %while this is satisfying intellectually,
                    %in my testing it didn't seem to make a big difference in policy value,
                    %and it definitely slowed down the algorithm (i.e. from 6 seconds to 9 seconds in my testing)
                    %m_v = max(post_values);
                    %m_i = find(post_values == m_v);
                    %a_i = m_i(randi(numel(m_i)));

                    %this is the other option to the above commented out code
                    %rather than selecting a random action of highest value we just pick the first one
                    [~,a_i] = max(post_v_vs);

                    X_s_m{m}{t} = t_s(post_s_as(:,a_i));
                    X_b_m{m}(t) = post_v_is(a_i);

                    s_t = X_s_m{m}{t};
                    
                end
            end

            init_states(init_count + (1:init_growth)) = horzcat(X_s_m{:});
            init_count = init_count + init_growth;

        time(2) = time(2) + toc(start);

        start = tic;
            for m = 1:M
                X_rewd = cellfun(reward, X_s_m{m});
                for w = 1:W
                    i = X_b_m{m}(w);
                    y = g_mat(w,:) * X_rewd';
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

                        b = (1-eta(i))*beta(i) + eta(i)*e;
                        v = (1-eta(i))*nu(i) + eta(i)*(e^2);
                        s = (v - b^2)/(1+lambda(i));

                        if(k > 2)
                            assert(~( (s/v) > 10000 || any(isnan([e, b, v, s, s/v])) || any(isinf([e, b, v, s, s/v])) ))
                        end

                        epsilon(i) = e;
                        beta   (i) = b;
                        nu     (i) = v;
                        sig_sq (i) = s;

                        Y(i) = (1-alpha(i))*Y(i) + alpha(i)*y;
                        K(i) = k + 1;
                        J(i) = 1/3*J(i) + 2/3*n;

                        l = ((1-alpha(i))^2)*lambda(i) + alpha(i)^2;

                        %the book suggests k <= 2... but it just seems to take longer
                        %for my particlar setup to get an estimate of the bias
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

                        %while it seems incorrect... I think it is ok for
                        %alpha to be less than one... I think... any([a,e] < 0)
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
                        nu     (i) = 0; % we don't use for a few iterations
                        alpha  (i) = 1;
                        eta    (i) = 1;
                        lambda (i) = 0; % we don't use for a few iterations
                    end
                end
            end
        time(3) = time(3) + toc(start);

        start = tic;

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(Y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(Y)/1.349;
            end

            X = vertcat(v_p(:,~isnan(Y)), J(~isnan(Y)));

            v_m = fitrsvm(X',Y(~isnan(Y))','KernelFunction','rbf', 'BoxConstraint', box_constraint, 'Solver', 'SMO', 'Standardize',true);
            v_v = predict(v_m, vertcat(v_p, n*ones(1,v_n))')';

        time(4) = time(4) + toc(start);
    end

    start = tic;
        values = @(s) v_v(v_i(s));
        policy = @(s) best_action_from_state(s, a_v(s), t_d, values);
    time(5) = time(5) + toc(start);
end