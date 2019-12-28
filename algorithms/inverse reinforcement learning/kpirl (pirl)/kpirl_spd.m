function [reward_function, time_measurements] = kpirl_spd(domain)

    a_tic = tic;
        [e_t       ] = feval([domain '_episodes']);
        [r_p, r_i  ] = feval([domain '_features'], 'reward');
        [parameters] = feval([domain '_parameters']);

        epsilon = parameters.epsilon;
        gamma   = parameters.gamma;
        kernel  = parameters.kernel;

        r_n = r_i();
        r_p = r_p(1:r_n);
        r_e = @(s) double((1:r_n)' == r_i(s));

        s_E = episodes2expect(e_t(), r_e, gamma);

        r_f = {};
        s_e = {};
        s_b = {};
        t_s = {};

        i = 0;

        while 1
            i = i + 1;

            tic_id = tic;
                if i == 1
                    r_v    = rand(size(r_p,1),1)'*r_p;
                    r_f{i} = @(s) r_v(r_i(s));
                    t_s{i} = Inf;
                else
                    n_z    = (s_E ~= 0) | (s_b{i-1} ~= 0);
                    r_g    = kernel(r_p(:,n_z),r_p);
                    t_g    = kernel(r_p(:,n_z),r_p(:,n_z));
                    r_v    = (s_E(n_z)-s_b{i-1}(n_z))'*r_g;
                    r_f{i} = @(s) r_v(r_i(s));
                    t_s{i} = sqrt(s_E(n_z)'*t_g*s_E(n_z) + s_b{i-1}(n_z)'*t_g*s_b{i-1}(n_z) - 2*s_E(n_z)'*t_g*s_b{i-1}(n_z));
                end

                s_e{i} = episodes2expect(e_t(r_f{i}), r_e, gamma);

                if i == 1
                    s_b{i} = s_e{i};
                else
                    n_z    = (s_E ~= 0) | (s_b{i-1} ~= 0) | (s_e{i} ~= 0);
                    s_g    = kernel(r_p(:,n_z), r_p(:,n_z));
                    s_n    = (s_e{i}(n_z)-s_b{i-1}(n_z))'*s_g*(   s_E(n_z)-s_b{i-1}(n_z));
                    s_d    = (s_e{i}(n_z)-s_b{i-1}(n_z))'*s_g*(s_e{i}(n_z)-s_b{i-1}(n_z));
                    s_b{i} = s_b{i-1} + (s_n/s_d) * (s_e{i}-s_b{i-1});
                end
            time_measurements = toc(tic_id);

            if ~exist('silent', 'var')
                fprintf('Completed IRL algorithm, i=%03d, t=%8.6f, time=%06.3f\n',[i,t_s{i},time_measurements]);
            end

            if  (i > 1) && (abs(t_s{i}-t_s{i-1}) <= epsilon) || (t_s{i} <= epsilon)
                break;
            end            
        end

        s_m = cell2mat(s_e);
        n_z = (s_E ~= 0) | any(s_m ~= 0,2);
        t_g = kernel(r_p(:,n_z), r_p(:,n_z));
        t_d = (s_E(n_z)-s_m(n_z,:));

        %Abbeel and Ng offer no method to select a single reward/policy from their algorithm. 
        %Their recommendation is to manually inspect all policies returned for appropriateness.
        %In the IRL Toolkit Levine solves this problem with CVX to find the convex combination 
        %of policies closest to the expert. From this combination the policy with the largest 
        %coefficient is then selected. To remove the dependency on CVX, and thus make this code,
        %easier to use we instead simply use the policy closest to the expert feature expectation.
        [~,m_i] = min(diag(t_d'*t_g*t_d));

        reward_function = r_f{m_i};
    time_measurements = toc(a_tic);

end