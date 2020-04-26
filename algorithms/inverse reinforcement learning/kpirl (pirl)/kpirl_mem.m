function [reward_function, time_measurements] = kpirl_mem(domain)

    a_tic = tic;
        [r2e         ] = feval([domain '_episodes']);
        [s2f         ] = feval([domain '_features'], 'reward');
        [edges, parts] = feval([domain '_discrete'], 'reward');
        [params      ] = feval([domain '_parameters']);

        [s2i, i2d] = discrete(s2f, edges, parts);

        epsilon = params.epsilon;
        gamma   = params.gamma;
        kernel  = params.r_kernel;

        reward_function = {};
        mu              = {};
        mu_bar          = {};
        
        i    = 1;
        mu_E = calculate_visitation(r2e(), gamma, s2i);
        X    = cat_hashtable(containers.Map('KeyType','double','ValueType','any'), keys(mu_E), num2cell(i2d(keys(mu_E)),1));

        tic_id = tic;
            reward_values      = rand(1,numel(s2i()));
            reward_function{i} = @(s) reward_values(s2i(s));
            
            mu{i}              = calculate_visitation(r2e(reward_function{i}), gamma, s2i);
            X                  = cat_hashtable(X, keys(mu{i}), num2cell(i2d(keys(mu{i})),1));

            basis = cell2mat(values(X));
            
            mu_bar{i}          = mu{i};

            t_E    = cell2mat(values(pad_hashtable(mu_E     , keys(X), 0)))';
            t_bar  = cell2mat(values(pad_hashtable(mu_bar{i}, keys(X), 0)))';

            t = gramian_dist(t_E-t_bar, kernel(basis, basis));
            j = inf;
        time_measurements = toc(tic_id);
        
        print_status(i, t, j, time_measurements);
        
        while t > epsilon && j > epsilon
            i = i + 1;
            
            tic_id = tic;
                alpha = cell2mat(values(sub_hashtables(mu_E, mu_bar{i-1})))';

                reward_function{i} = @(s) alpha'*kernel(basis, i2d(s2i(s)));

                mu{i} = calculate_visitation(r2e(reward_function{i}), gamma, s2i);
                X     = cat_hashtable(X, keys(mu{i}), num2cell(i2d(keys(mu{i})),1));

                basis      = cell2mat(values(X));
                basis_gram = kernel(basis, basis);
                
                s_k  = keys(X);

                s_1 = sub_hashtables(mu{i},mu_bar{i-1});
                s_2 = sub_hashtables( mu_E,mu_bar{i-1});
                s_3 = mu_bar{i-1};

                s_1  = cell2mat(values(pad_hashtable(s_1, s_k, 0)))';
                s_2  = cell2mat(values(pad_hashtable(s_2, s_k, 0)))';
                s_3  = cell2mat(values(pad_hashtable(s_3, s_k, 0)))';

                theta_num = s_1'*basis_gram*s_2;
                theta_den = s_1'*basis_gram*s_1;

                mu_bar_vals = s_3 + (theta_num/theta_den) * s_1;

                mu_bar{i} = containers.Map(s_k, num2cell(mu_bar_vals'));

                s_4  = cell2mat(values(pad_hashtable(sub_hashtables(mu_E       ,mu_bar{i}), s_k, 0)))';
                s_5  = cell2mat(values(pad_hashtable(sub_hashtables(mu_bar{i-1},mu_bar{i}), s_k, 0)))';
                
                t = gramian_dist(s_4, basis_gram);
                j = gramian_dist(s_5, basis_gram);

            time_measurements = toc(tic_id);
            
            print_status(i, t, j, time_measurements);
        end
        
        t_E   =                         cell2mat(values(pad_hashtable(mu_E, keys(X), 0)))';
        t_mu  = cell2mat(cellfun(@(s) { cell2mat(values(pad_hashtable(s   , keys(X), 0)))' }, mu));
        basis = cell2mat(values(X));
        
        %Abbeel and Ng offer no method to select a single reward/policy from their algorithm. 
        %Their recommendation is to manually inspect all policies returned for appropriateness.
        %In the IRL Toolkit Levine solves this problem with CVX to find the convex combination 
        %of policies closest to the expert. From this combination the policy with the largest 
        %coefficient is then selected. To remove the dependency on CVX, and thus make this code,
        %easier to use we instead simply use the policy closest to the expert feature expectation.
        [~,m_i] = min(gramian_dist(t_E - t_mu, kernel(basis,basis)));

        reward_function = reward_function{m_i};
    time_measurements = toc(a_tic);

end

function visitation_hashtable = calculate_visitation(episodes, gamma, r_i)

    visitation_hashtable = containers.Map('KeyType','double','ValueType','any');

    for m = 1:numel(episodes)
        for t = 1:size(episodes{m},2)

            if iscell(episodes{m})
                key = r_i(episodes{m}{t});
            else
                key = r_i(episodes{m}(:,t));
            end

            if ~isKey(visitation_hashtable, key)
                visitation_hashtable(key) = 0;
            end
            
            visitation_hashtable(key) = visitation_hashtable(key) + gamma^(t-1);
            
        end
    end

    for key = keys(visitation_hashtable)
        visitation_hashtable(key{1}) = visitation_hashtable(key{1}) / numel(episodes);
    end
end

function padded_hashtable = pad_hashtable(hashtable, keys, value)
    padded_hashtable = cat_hashtable(hashtable, keys, repmat(value,1,numel(keys)));
end

function subbed_hashtable = sub_hashtables(hashtable1, hashtable2)
    subbed_hashtable = containers.Map('KeyType','double','ValueType','any');
    
    for key = [keys(hashtable1), keys(hashtable2)]
        
        if isKey(hashtable1,key)
            val1 = hashtable1(key{1});
        else
            val1 = 0;
        end
        
        if isKey(hashtable2,key)
            val2 = hashtable2(key{1});
        else
            val2 = 0;
        end
        
        subbed_hashtable(key{1}) = val1 - val2;
    end
end

function catted_hashtable = cat_hashtable(hashtable, keys, values)
    new_hashtable = containers.Map(keys, values);
    
    catted_hashtable = [new_hashtable; hashtable];
end

function d = gramian_dist(vectors, gramian)
    d = sqrt(diag(vectors'*gramian*vectors));
end

function print_status(i, t, j, time)
    fprintf('Finished iteration %03d with t=%09.6f, j=%09.6f, time=%06.3f\n',[i,t,j,time]);
end