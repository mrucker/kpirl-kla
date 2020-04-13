function [reward_function, time_measurements] = kpirl_spd(domain)

    a_tic = tic;
        [params      ] = feval([domain '_parameters']);    
        [r2e         ] = feval([domain '_episodes']);
        [s2f         ] = feval([domain '_features'], 'reward');
        [edges, parts] = feval([domain '_discrete'], 'reward');

        [s2d, s2i] = discretes(s2f, edges, parts);

        epsilon = params.epsilon;
        gamma   = params.gamma;
        kernel  = params.r_kernel;

        r_n = s2i(); %determine this value once
        
        s2d = s2d(1:r_n);
        s2d = @(is) s2d(:,is); %this makes r_p behave identically to before except that it is already calculated.

        e_hat = @(s) double((1:r_n)' == s2i(s));

        reward_function = {};
        mu              = {};
        mu_bar          = {};

        i    = 1;
        mu_E = episodes2expect(r2e(), e_hat, gamma);
        
        tic_id = tic;
            reward_values      = rand(1,r_n);
            reward_function{i} = @(s) reward_values(s2i(s));
            mu{i}              = episodes2expect(r2e(reward_function{i}), e_hat, gamma);

            %to avoid having a huge set of basis functions 
            %we remove all feature vectors with zero weight.
            n_z                = find((mu_E ~= 0) | (mu{i} ~= 0));
            basis              = s2d(n_z);

            mu_bar{i}          = mu{i};

            t                  = kern_dist(mu_E(n_z)-mu_bar{i}(n_z), kernel, s2d);
            j                  = inf;
        time_measurements = toc(tic_id);
        
        print_status(i, t, j, time_measurements);
        
        %convergence can really slow down over time, especially with the noise from approximate solutions
        %therefore we add an additional termination condition in practice that sees if the solutions are 
        %converging to eachother. This second check could probably be improved by finding the average j distance.
        while t > epsilon && j > epsilon
            i = i + 1;

            tic_id = tic;
                alpha              = mu_E(n_z)-mu_bar{i-1}(n_z);
            
                reward_values      = alpha'*kernel(basis, s2d(1:r_n));
                reward_function{i} = @(s) reward_values(s2i(s));

                mu{i} = episodes2expect(r2e(reward_function{i}), e_hat, gamma);

                n_z        = find((mu_E ~= 0) | (mu{i} ~= 0) | (mu_bar{i-1} ~= 0));
                basis      = s2d(n_z);
                basis_gram = kernel(basis, basis);

                theta_num = (mu{i}(n_z)-mu_bar{i-1}(n_z))'*basis_gram*(mu_E(n_z) -mu_bar{i-1}(n_z));
                theta_den = (mu{i}(n_z)-mu_bar{i-1}(n_z))'*basis_gram*(mu{i}(n_z)-mu_bar{i-1}(n_z));
                theta     = (theta_num/theta_den);

                mu_bar{i} = mu_bar{i-1} + theta * (mu{i}-mu_bar{i-1});

                t = gram_dist(mu_E(n_z)-mu_bar{i}(n_z), basis_gram);
                j = kern_dist(mu_bar{i}-mu_bar{i-1}, kernel, s2d);
            time_measurements = toc(tic_id);
            
            print_status(i, t, j, time_measurements);
        end

        %Abbeel and Ng offer no method to select a single reward/policy from their algorithm. 
        %Their recommendation is to manually inspect all policies returned for appropriateness.
        %In the IRL Toolkit Levine solves this problem with CVX to find the convex combination 
        %of policies closest to the expert. From this combination the policy with the largest 
        %coefficient is then selected. To remove the dependency on CVX, and thus make this code,
        %easier to use we instead simply use the policy closest to the expert feature expectation.
        [~,m_i] = min(kern_dist(mu_E - cell2mat(mu), kernel, s2d));

        reward_function = reward_function{m_i};
    time_measurements = toc(a_tic);

end

function d = kern_dist(weights, kernel, features)
    n_z     = find(any(weights ~= 0,2));
    basis   = features(n_z);
    weights = weights(n_z,:);
    
    d = gram_dist(weights, kernel(basis,basis));
end

function d = gram_dist(vectors, gramian)
    d = sqrt(diag(vectors'*gramian*vectors));
end

function print_status(i, t, j, time)
    fprintf('Finished iteration %03d with t=%09.6f, j=%09.6f, time=%06.3f\n',[i,t,j,time]);
end