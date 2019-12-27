function [reward_function, time_measurements] = kpirl_mem(domain)

    a_tic = tic;
        [E_t       ] = feval([domain '_expert_episodes']);
        [r_p, r_i  ] = feval([domain '_reward_features']);
        [parameters] = feval([domain '_parameters']);

        epsilon = parameters.epsilon;
        gamma   = parameters.gamma;
        kernel  = parameters.kernel;

        X = containers.Map('KeyType','double','ValueType','any');

        s_E = calculate_visitation(E_t, gamma, r_i);
        X   = cat_hashtable(X, keys(s_E), num2cell(r_p(keys(s_E)),1));

        r_f = {};
        s_e = {};
        s_b = {};
        t_s = {};

        i = 0;
        
        while 1
            i = i + 1;

            tic_id = tic;
                if i == 1
                    r_w    = rand(r_p(),1);
                    r_f{i} = @(s) r_w'*r_p(s);
                    t_s{i} = Inf;
                else

                    r_w    = cell2mat(values(sub_hashtables(s_E, s_b{i-1})))';
                    r_x    = cell2mat(values(X));

                    r_f{i} = @(s) r_w'*kernel(r_x, r_p(s));

                    t_g    = kernel(cell2mat(values(X)), cell2mat(values(X)));
                    t_E    = cell2mat(values(pad_hashtable(s_E     , keys(X), 0)))';
                    t_b    = cell2mat(values(pad_hashtable(s_b{i-1}, keys(X), 0)))';
                    t_s{i} = sqrt(t_E'*t_g*t_E + t_b'*t_g*t_b - 2*t_E'*t_g*t_b);
                end

                s_t    = feval([domain, '_reward_episodes'], r_f{i});
                s_e{i} = calculate_visitation(s_t, gamma, r_i);
                X      = cat_hashtable(X, keys(s_e{i}), num2cell(r_p(keys(s_e{i})),1));

                if i == 1
                    s_b{i} = s_e{i};
                else
                    s_k  = keys(X);
                    s_g  = kernel(cell2mat(values(X)), cell2mat(values(X)));

                    s_1 = sub_hashtables(s_e{i},s_b{i-1});
                    s_2 = sub_hashtables(   s_E,s_b{i-1});
                    s_3 = s_b{i-1};

                    s_1  = cell2mat(values(pad_hashtable(s_1, s_k, 0)))';
                    s_2  = cell2mat(values(pad_hashtable(s_2, s_k, 0)))';
                    s_3  = cell2mat(values(pad_hashtable(s_3, s_k, 0)))';

                    s_n    = s_1'*s_g*s_2;
                    s_d    = s_1'*s_g*s_1;
                    s_v    = s_3 + (s_n/s_d) * s_1;

                    s_b{i} = containers.Map(s_k, num2cell(s_v'));
                end
            time_measurements = toc(tic_id);

            if ~exist('silent', 'var')
                fprintf('Completed IRL algorithm, i=%03d, t=%8.6f, time=%06.3f\n',[i,t_s{i},time_measurements]);
            end

            if  (i > 1) && (abs(t_s{i}-t_s{i-1}) <= epsilon) || (t_s{i} <= epsilon)
                break;
            end
        end

        for i = 1:numel(s_e)
        end
        
        t_E = cell2mat(values(pad_hashtable(s_E, keys(X), 0)))';
        t_m = cell2mat(cellfun(@(s) { cell2mat(values(pad_hashtable(s,keys(X),0)))' }, s_e));
        t_g = kernel(cell2mat(values(X)), cell2mat(values(X)));
        t_d = t_E-t_m;

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