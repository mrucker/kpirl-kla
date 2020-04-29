function [policy, time, policies, times] = kla_core(domain, reward, indexable_store, indexable_func); global fitrsvm_kernel;

    gcp; %this is here to force the parallel pool to begin before we start timing

    start = tic;

        [params      ] = feval([domain '_parameters']);
        [s2a         ] = feval([domain '_actions']);
        [s2s, s2p    ] = feval([domain '_transitions']);
        [s2f         ] = feval([domain '_features'], 'value');
        [edges, parts] = feval([domain '_discrete'], 'value');

        [f2i, i2d] = discrete(edges, parts);
        [s2i     ] = @(s) f2i(s2f(s));
        
        
        i2d = indexable_func(i2d);

        Q_bar     = indexable_func(@(is) ones(1,numel(is)));
        Q_dot     = indexable_store(0);
        OSA_store = indexable_OSA_store(indexable_store([0; 0; 0; 0; 0; 0]));

        if(isa(params.v_kernel,'function_handle'))
            fitrsvm_kernel = params.v_kernel;
            KernelFunction = 'fitrsvm_kernel_caller';
        else
            KernelFunction = params.v_kernel;
        end
        
        N     = params.N;
        M     = params.M;
        T     = params.T;
        W     = params.W;
        gamma = params.gamma;

        explore_type = get_or_default(params, 'explore', 1);
        target_type  = get_or_default(params, 'target' , 0);
        smooth_type  = get_or_default(params, 'smooth' , 1);

        time     = zeros(5,1);
        policies = cell (1,N);
        times    = zeros(5,N);
        
        g_mat = cell2mat(arrayfun(@(w) { [zeros(1,w) gamma.^(0:T-1) zeros(1,W-w)] }, 0:W-1)');
    time(1) = toc(start);

    policies{1} = @(s) randargmax(@(as) zeros(1,size(as,2)), s2a(s));
    times(:,1)  = zeros(5,1);

    for n = 2:N

        start = tic;
            E = get_explore_function(explore_type, OSA_store);
            O = zeros(2,W,M);
        time(2) = time(2) + toc(start);

        start = tic;
            for m = 1:M
                i = zeros(1,T+W);
                r = zeros(1,T+W);
                s = s2s();

                for t = 1:T+W
                    ps = s2p(s,s2a(s));
                    is = s2i(ps);

                    if t == 1
                        [i(t), p_i] = randargmax(@(is) Q_bar(is) + E(is), is);
                    else
                        [i(t), p_i] = randargmax(@(is) Q_bar(is), is);
                    end

                    %I don't need the last iteration of this
                    s    = s2s(ps(:,p_i));
                    r(t) = reward(s);
                end

                if target_type == 0 % monte carlo
                    q = r * g_mat';
                end

                if target_type == 1 % bootstrap
                    q = r(1:W) + gamma * Q_bar(i(1 + (1:W)));
                end

                O(:,:,m) = vertcat(i(1:W),q);
            end
        time(3) = time(3) + toc(start);

        start = tic;
            for o = reshape(O,2,M*W)
                i = o(1);
                q = o(2);

                Q = Q_dot(i);
                [c, beta, delta, ~, nu, lambda] = OSA_store(i);

                %these step size calculations taken from Pg. 446-447 in
                %Approximate Dynamic Programming (2011) by Powell and
                %Adaptive stepsizes for recursive estimation with applications 
                %in approximate dynamic programming (2006)

                c = c + 1;

                if (c == 1 || c == 2)
                    nu = 1;
                else
                    nu = nu/(.95+nu);
                end

                beta  = (1-nu)*beta + nu*(q - Q); %be careful with this, Powell reverses it between his book and paper
                delta = (1-nu)*delta + nu*(q - Q)^2;
                var   = (delta - beta^2)/(1+lambda);

                if smooth_type == 0 % sample averaging
                    alpha = 1/c;
                end

                if smooth_type == 1 % OSA optimal step-size
                    if (c == 1 || c == 2 || c == 3 || delta == 0)
                        alpha = 1/c;
                    else
                        alpha = 1 - (var/delta);
                    end
                end

                Q      = (1-alpha)*Q + alpha*q; % = Q + alpha*(q-Q)
                lambda = lambda*(1-alpha)^2 + alpha^2;

                assert(~any([alpha, nu, lambda] > 1));
                assert(~any(isnan([beta, delta, var, alpha, nu, lambda])));
                assert(~any(isinf([beta, delta, var, alpha, nu, lambda])))

                Q_dot(i, Q);
                OSA_store(i, [c; beta; delta; var; nu; lambda]);
            end
        time(4) = time(4) + toc(start);

        start = tic;
        
            [I,Y] = Q_dot();
            X     = i2d(I);
        
            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(Y) < .0001
                BoxConstraint = 1;
            else
                BoxConstraint = iqr(Y)/1.349;
            end

            m = fitrsvm(X', Y', 'KernelFunction',KernelFunction, 'BoxConstraint',BoxConstraint);
            
            if(any(strcmp(m.KernelParameters.Function, ["linear","gaussian","rbf","polynomial"])))
                p = @(is) m.predict(i2d(is));
            else
                %for some reason m.predict runs slower with custom kernels so we handle them manually
                %https://www.mathworks.com/matlabcentral/answers/516513-fitrsvm-doesn-t-vectorize-my-custom-kernel
                p = @(is) m.Bias + m.Alpha' * feval(m.KernelParameters.Function, m.SupportVectors, i2d(is)');
            end
            
            Q_bar = indexable_func(p);

        time(5) = time(5) + toc(start);

        policies{n} = @(s) randargmax(@(as) Q_bar(s2i(s2p(s, as))), s2a(s));
        times(:,n)  = time;
    end

    policy = policies{end};
    time   = times(:,end);
    
    clear k_fitrsvm_kernel
    
end

function f = indexable_OSA_store(indexable_store)

    f = @indexable_OSA_store;

    function varargout = indexable_OSA_store(keys,values)
        if(nargin == 0)
            [varargout{1}, varargout{2}] = indexable_store();
        end

        if(nargin == 1)
            varargout = num2cell(indexable_store(keys),2);
        end

        if(nargin == 2)
            indexable_store(keys,values);
        end
    end
end

function U = get_OSA_U(OSA_store, is)
    [~, beta, ~, var, ~, lambda] = OSA_store(is);
    U = beta + 2*sqrt(lambda.*var);
end

function U = get_OSA_max_U(OSA_store)

    [c, beta, ~, var, ~, lambda] = OSA_store(OSA_store());

    if(all(c < 3))
        U = 0;
    else
        U = beta + 2*sqrt(lambda.*var);
        U = max(U(c >= 3));    
    end

end

function f = get_explore_function(explore_type, OSA_store)

    max_U = get_OSA_max_U(OSA_store);

    if explore_type == 0 %no-exploration
        f = @(is) zeros(1, size(is,2));
    end

    if explore_type == 1 %UCB-exploration
        f = @(is) sum(xor(repmat((OSA_store(is) >= 3),2,1),[false;true]) .* vertcat(get_OSA_U(OSA_store, is), max_U * ones(size(is))));
    end

    if explore_type == 2 %random-exploration
        f = @(is) 100*rand(1, size(is,1));
    end
end