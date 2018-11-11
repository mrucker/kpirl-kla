function [reward,time] = kpirl(domain, kernel)

    a_tic = tic;
        [s_e       ] = feval([domain '_trajectories']);
        [r_i, r_p  ] = feval([domain '_reward_basii']);
        [paramaters] = feval([domain '_paramaters']);

        epsilon = paramaters.epsilon;
        gamma   = paramaters.gamma;

        r_n = size(r_p,2);
        r_e = @(s) double((1:r_n)' == r_i(s));

        E = expectation_from_trajectories(s_e, r_e, gamma);

        reward_features_gram = kernel(r_p,r_p);

        rs = {};
        ss = {};
        sb = {};
        ts = {};

        i  = 1;

        rs{i} = rand(size(r_p,2),1)'*reward_features_gram;
        ss{i} = feval([domain, '_expectations'], @(s) rs{i}(r_i(s)) );
        sb{i} = ss{i};
        ts{i} = Inf;

        i = 2;

        while 1

            rs{i} = (E-sb{i-1})'*reward_features_gram;
            ss{i} = feval([domain, '_expectations'], @(s) rs{i}(r_i(s)) );
            ts{i} = sqrt(E'*reward_features_gram*E + sb{i-1}'*reward_features_gram*sb{i-1} - 2*E'*reward_features_gram*sb{i-1});

            if  (abs(ts{i}-ts{i-1}) <= epsilon) || (ts{i} <= epsilon)
                break;
            end

            sn    = (ss{i}-sb{i-1})'*reward_features_gram*(E-sb{i-1});
            sd    = (ss{i}-sb{i-1})'*reward_features_gram*(ss{i}-sb{i-1});
            sc    = sn/sd;
            sb{i} = sb{i-1} + sc*(ss{i}-sb{i-1});

            i = i + 1;
        end

        %Abbeel and Ng suggested solving a convex optimization problem and choosing
        %the ss with the largest coefficient. This approach didn't seem to have a big
        %effect on the outcomes in our problem domains and introduced dependencies on 
        %external solvers like CVX. Therefore, we use this method to make this code
        %more accessible to new developers. If you are an advanced user and want to use
        %the convex optimization approach then you need to replace this line.
        [~,m_i] = min(diag((E-cell2mat(ss))'*reward_features_gram*(E-cell2mat(ss))));

        reward = rs{m_i};
    time = toc(a_tic);

end