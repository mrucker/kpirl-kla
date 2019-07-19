function phi = huge_value_basis_klspi(state, actions, dic_data, para); persistent t_d v_i v_p;

    if(isempty(t_d))
        [t_d] = huge_transitions();
    end

    if(isempty(v_p))        
        [v_i, v_p] = huge_value_basis();
        
        v_p = v_p(1:v_i()); % all basis permuations
    end
    
    if(nargin == 0)
        phi = size(v_p,1);
    end

    if(nargin == 1 && ~isempty(state))
        phi = v_i(state);
    end

    if(nargin==2)
        phi = v_p(:,v_i(t_d(state, actions)));
    end

    if(nargin > 2)

        width = para;

        if(~isempty(state))
            state_feature = v_p(:,v_i(t_d(state, actions)));
        else
            state_feature = v_p;
        end
                                
        if(size(state_feature,2) == 1)
            phi = exp(-vecnorm(state_feature-dic_data').^2/width^2)';
        else
            phi = cell2mat(arrayfun(@(c)exp(-vecnorm(state_feature(:,c)-dic_data').^2/para(1)^2)', 1:size(state_feature,2), 'UniformOutput', false));
        end
    end
end