function phi = huge_value_basii_lspi(state, actions, ~, ~); persistent t_d v_i v_p v_l; 

    if(isempty(t_d))
        [t_d] = huge_transitions();
    end

    if(isempty(v_p))
        [v_i, v_p, v_l] = huge_value_basii();

        %v_p = full_radial_basis_features(v_p());
        %v_p = full_2nd_order_polynomial_features(v_p());
        v_p = full_3rd_order_polynomial_features(v_p());
        %v_p = full_2nd_order_polynomial_features(full_radial_basis_features(v_p()));
    end
    
    if(nargin == 0)
        phi = size(v_p,1);
    end

    if(nargin == 1 && isempty(state))
        phi = v_p;
    end

    if(nargin == 1 && ~isempty(state))
        phi = v_i(v_l(state));
    end
    
    if(nargin==2)
        phi = v_p(:,v_i(v_l(t_d(state, actions))));
    end
    
    if(nargin > 2)
        %(state, action, dic_data, para)
    end
end

function v_p = full_radial_basis_features(v_p)
    LEVELS_N = [3 3 3 3 3 3 1 1 1 6];
    LEVELS_S = [1/2 1/2 1/2 1/2 1/2 1/2 .001 .001 .001 2/5];

    v_p = cell2mat(arrayfun(@(r) repmat(v_p(r,:),LEVELS_N(r),1), 1:numel(LEVELS_N), 'UniformOutput',false)');        
    v_s = cell2mat(arrayfun(@(r) LEVELS_S(r)*ones(LEVELS_N(r),1), 1:numel(LEVELS_N), 'UniformOutput',false)');
    v_c = [0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 1/1 1/1 1/1 0/5 1/5 2/5 3/5 4/5 5/5]';

    v_p = v_p - v_c;
    v_p = power(v_p,2);
    v_p = v_p ./(2*power(v_s,2));
    v_p = exp(-v_p);
end

function v_p = full_2nd_order_polynomial_features(v_p)

    first_order_feature_count = size(v_p,1);
    
    for i = 1:first_order_feature_count
        for j = i:first_order_feature_count
            %add in second order components
            v_p = vertcat(v_p, v_p(i,:).*v_p(j,:));
        end
    end
end

function v_p = full_3rd_order_polynomial_features(v_p)

    first_order_feature_count = size(v_p,1);
    
    for i = 1:first_order_feature_count
        for j = i:first_order_feature_count
            %add in second order components
            v_p = vertcat(v_p, v_p(i,:).*v_p(j,:));

            for k = j:first_order_feature_count
                %add in third order components
                v_p = vertcat(v_p, v_p(i,:).*v_p(j,:).*v_p(k,:));
            end
        end
    end
end