function [reward_function, time_measurements] = kpirl_core(domain)

    a_tic = tic;
        [params      ] = feval([domain '_parameters']);    
        [r2e         ] = feval([domain '_episodes']);
        [s2f         ] = feval([domain '_features'], 'reward');
        [edges, parts] = feval([domain '_discrete'], 'reward');

        [f2i, i2d] = discrete(edges, parts);
        [s2i     ] = @(s) f2i(s2f(s));

        epsilon = params.epsilon;
        gamma   = params.gamma;
        kernel  = params.r_kernel;

        reward_function = {};
        reward_visits   = {};
        convex_visits   = {};
        expert_visits   = episodes2visits(r2e(), s2i, gamma);

        i = 1;

        tic_id = tic;
            reward_weights     = rand(size(i2d(1)));

            reward_function{i} = @(s) reward_weights' * i2d(s2i(s));
            reward_episodes    = r2e(reward_function{i});
            reward_visits{i}   = episodes2visits(reward_episodes, s2i, gamma);
            convex_visits{i}   = reward_visits{i};

            t                  = discrete_distance(expert_visits, convex_visits{i}, kernel, i2d);
            j                  = inf;
        time_measurements = toc(tic_id);
        
        print_status(i, t, j, time_measurements);
        
        %convergence can really slow down over time, especially with the noise from approximate solutions
        %therefore we add an additional termination condition in practice that sees if the solutions are 
        %converging to eachother. This second check could probably be improved by finding the average j distance.
        while t > epsilon && j > epsilon
            i = i + 1;

            tic_id = tic;
                union  = union_index({expert_visits, convex_visits{i-1}});
                alpha  = (expert_visits(union)-convex_visits{i-1}(union))';
                basis  = i2d(union);

                reward_function{i} = @(s) alpha'*kernel(basis, i2d(s2i(s)));
                reward_episodes    = r2e(reward_function{i});
                reward_visits{i}   = episodes2visits(reward_episodes, s2i, gamma);

                union = union_index({expert_visits, reward_visits{i}, convex_visits{i-1}});
                basis = i2d(union);
                gram  = kernel(basis, basis);

                theta_num = (reward_visits{i}(union)-convex_visits{i-1}(union))*gram*(expert_visits(union)-convex_visits{i-1}(union))';
                theta_den = (reward_visits{i}(union)-convex_visits{i-1}(union))*gram*(reward_visits{i}(union)-convex_visits{i-1}(union))';
                theta     = (theta_num/theta_den);
                
                convex_visits{i} = reward2convex(reward_visits{i}, convex_visits{i-1}, theta);

                t = discrete_distance(expert_visits, convex_visits{i}, kernel, i2d);
                j = discrete_distance(convex_visits{i}, convex_visits{i-1}, kernel, i2d);
            time_measurements = toc(tic_id);

            print_status(i, t, j, time_measurements);
        end

        %Abbeel and Ng offer no method to select a single reward/policy from their algorithm. 
        %Their recommendation is to manually inspect all policies returned for appropriateness.
        %In the IRL Toolkit Levine solves this problem with CVX to find the convex combination 
        %of policies closest to the expert. From this combination the policy with the largest 
        %coefficient is then selected. To remove the dependency on CVX, and thus make this code,
        %easier to use we instead simply use the policy closest to the expert feature expectation.
        [~,m_i] = min(cellfun(@(r) discrete_distance(expert_visits, r, kernel, i2d), reward_visits));

        reward_function = reward_function{m_i};
    time_measurements = toc(a_tic);

end

function m = reward2convex(reward_visits, convex_visits, theta)

    union = union_index({reward_visits, convex_visits});

    m = fast_index(0);
    m(union, convex_visits(union) + theta * (reward_visits(union)-convex_visits(union)));
end

function m = episodes2visits(episodes, s2i, gamma)

    m = fast_index(0);
    
    n_episodes = numel(episodes);

    for e = episodes
        for t = 1:numel(e{1})
            i = s2i(e{1}{t});
            v = gamma^(t-1);
            m(i, m(i) + v/n_episodes);
        end
    end

end

function is = union_index(indexable_interfaces)
    is = unique(cell2mat(cellfun(@(i) {i()}, indexable_interfaces)));
end

function dist = discrete_distance(visitation_1, visitation_2, kernel, i2d)

    is = union_index({visitation_1, visitation_2});
    ds = i2d(is);
    
    diff = (visitation_1(is) - visitation_2(is));
    dist = sqrt(diff*kernel(ds,ds)*diff');
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