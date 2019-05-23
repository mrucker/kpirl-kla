function [reward_function, time_measurements, state_importance] = kpirl(domain)

    a_tic = tic;
        [s_e       ] = feval([domain '_trajectories']);
        [r_i, r_p  ] = feval([domain '_reward_basii']);
        [parameters] = feval([domain '_parameters']);

        epsilon = parameters.epsilon;
        gamma   = parameters.gamma;
        kernel  = parameters.kernel;

        r_n = size(r_p,2);
        r_e = @(s) double((1:r_n)' == r_i(s));

        E = expectation_from_trajectories(s_e, r_e, gamma);

        rs = {};
        ss = {};
        sb = {};
        ts = {};

        i = 1;

        tic_id = tic;
            rs{i} = rand(1,size(r_p,2));
            ss{i} = feval([domain, '_expectations'], @(s) rs{i}(r_i(s)) );
            sb{i} = ss{i};
            ts{i} = Inf;
        time_measurements = toc(tic_id);

        i = 2;

        while 1
            
            if ~exist('silent', 'var')
                fprintf('Completed IRL iteration, i=%03d, t=%8.6f, time=%06.3f\n',[i-1,ts{i-1},time_measurements]);
            end
            
            tic_id = tic;
                nz    = (E ~= 0) | (sb{i-1} ~= 0);
                rg    = kernel(r_p(:,nz),r_p);
                
                rs{i} = (E(nz)-sb{i-1}(nz))'*rg;
                ss{i} = feval([domain, '_expectations'], @(s) rs{i}(r_i(s)));
                
                nz    = (E ~= 0) | (sb{i-1} ~= 0);
                rg    = kernel(r_p(:,nz), r_p(:,nz));
                
                ts{i} = sqrt(E(nz)'*rg*E(nz) + sb{i-1}(nz)'*rg*sb{i-1}(nz) - 2*E(nz)'*rg*sb{i-1}(nz));                
            time_measurements = toc(tic_id);

            if  (abs(ts{i}-ts{i-1}) <= epsilon) || (ts{i} <= epsilon)
                break;
            end
            
            nz    = (E ~= 0) | (sb{i-1} ~= 0) | (ss{i} ~= 0);
            rg    = kernel(r_p(:,nz), r_p(:,nz));
            
            sn    = (ss{i}(nz)-sb{i-1}(nz))'*rg*(    E(nz)-sb{i-1}(nz));
            sd    = (ss{i}(nz)-sb{i-1}(nz))'*rg*(ss{i}(nz)-sb{i-1}(nz));
            sc    = sn/sd;
            sb{i} = sb{i-1} + sc * (ss{i}-sb{i-1});

            i = i + 1;
        end

            if ~exist('silent', 'var')
                fprintf('Completed IRL algorithm, i=%03d, t=%8.6f, time=%06.3f\n',[i,ts{i},time_measurements]);
            end

        sm = cell2mat(ss);
        nz = (E ~= 0) | any(sm ~= 0,2);
        rg = kernel(r_p(:,nz), r_p(:,nz));
            
        %Abbeel and Ng suggested solving a convex optimization problem and choosing
        %the ss with the largest coefficient. This approach didn't seem to have a big
        %effect on the outcomes in our problem domains and introduced dependencies on 
        %external solvers like CVX. Therefore, we use this method to make this code
        %more accessible to new developers. If you are an advanced user and want to use
        %the convex optimization approach then you need to replace this line.
        [~,m_i] = min(diag((E(nz)-sm(nz,:))'*rg*(E(nz)-sm(nz,:))));

        state_importance = E-sb{m_i-1};
        reward_function  = rs{m_i};
    time_measurements = toc(a_tic);

end