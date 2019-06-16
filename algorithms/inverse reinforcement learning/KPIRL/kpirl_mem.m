function [reward_function, time_measurements] = kpirl_mem(domain)

    a_tic = tic;
        [E_t       ] = feval([domain '_expert_trajectories']);
        [r_i, r_p  ] = feval([domain '_reward_basii']);
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

                s_t    = feval([domain, '_reward_trajectories'], r_f{i});
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

        %Abbeel and Ng suggested solving a convex optimization problem and choosing
        %the ss with the largest coefficient. This approach didn't seem to have a big
        %effect on the outcomes in our problem domains and introduced dependencies on 
        %external solvers like CVX. Therefore, we use this method to make this code
        %more accessible to new developers. If you are an advanced user and want to use
        %the convex optimization approach then you need to replace this line.
        [~,m_i] = min(diag(t_d'*t_g*t_d));

        reward_function = r_f{m_i};
    time_measurements = toc(a_tic);

end

function visitation_hashtable = calculate_visitation(trajectories, gamma, r_i)

    visitation_hashtable = containers.Map('KeyType','double','ValueType','any');

    for m = 1:numel(trajectories)
        for t = 1:size(trajectories{m},2)

            if iscell(trajectories{m})
                key = r_i(trajectories{m}{t});
            else
                key = r_i(trajectories{m}(:,t));
            end

            if ~isKey(visitation_hashtable, key)
                visitation_hashtable(key) = 0;
            end
            
            visitation_hashtable(key) = visitation_hashtable(key) + gamma^(t-1);
            
        end
    end

    for key = keys(visitation_hashtable)
        visitation_hashtable(key{1}) = visitation_hashtable(key{1}) / numel(trajectories);
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