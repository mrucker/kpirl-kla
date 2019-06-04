function [reward_function, time_measurements] = kpirl_mem(domain)

    a_tic = tic;
        [E_t          ] = feval([domain '_trajectories']);
        [r_l, r_i, r_p] = feval([domain '_reward_basii']);
        [parameters   ] = feval([domain '_parameters']);

        epsilon = parameters.epsilon;
        gamma   = parameters.gamma;
        kernel  = parameters.kernel;

        r_n = r_i();
        r_p = r_p(r_l());
        r_e = @(s) double((1:r_n)' == r_i(r_l(s)));

        E = expectation_from_trajectories(E_t, r_e, gamma);

        rs = {};
        ss = {};
        sb = {};
        ts = {};

        i = 0;

        while true
            i = i + 1;
            
            tic_id = tic;
                if i == 1
                    rs{i} = rand(1,r_n);
                    ts{i} = Inf;
                else
                    nz    = (E ~= 0) | (sb{i-1} ~= 0);
                    rr    = kernel(r_p(:,nz),r_p      );
                    rt    = kernel(r_p(:,nz),r_p(:,nz));

                    rs{i} = (E(nz)-sb{i-1}(nz))'*rr;
                    ts{i} = sqrt(E(nz)'*rt*E(nz) + sb{i-1}(nz)'*rt*sb{i-1}(nz) - 2*E(nz)'*rt*sb{i-1}(nz));
                end

                ss{i} = feval([domain, '_expectations'], @(s) rs{i}(r_i(r_l(s))));

                if i == 1
                    sb{i} = ss{i};
                else
                    nz    = (E ~= 0) | (sb{i-1} ~= 0) | (ss{i} ~= 0);
                    rb    = kernel(r_p(:,nz), r_p(:,nz));

                    sn    = (ss{i}(nz)-sb{i-1}(nz))'*rb*(    E(nz)-sb{i-1}(nz));
                    sd    = (ss{i}(nz)-sb{i-1}(nz))'*rb*(ss{i}(nz)-sb{i-1}(nz));
                    sb{i} = sb{i-1} + (sn/sd) * (ss{i}-sb{i-1});
                end
            time_measurements = toc(tic_id);

            if ~exist('silent', 'var')
                fprintf('Completed IRL iteration, i=%03d, t=%8.6f, time=%06.3f\n',[i,ts{i},time_measurements]);
            end
            
            if  (abs(ts{i}-ts{i-1}) <= epsilon) || (ts{i} <= epsilon)
                break;
            end
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

        reward_function = rs{m_i};
    time_measurements = toc(a_tic);

end