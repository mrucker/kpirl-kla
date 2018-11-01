function phi = huge_basii_v_klspi(state, action, dic_data, para); persistent v_i v_p v_l a_m; 

    if(isempty(a_m))
        s_a = s_act_4_2();
        a_m = s_a([]);
    end

    if(isempty(v_p))
        [v_i, v_p, ~, v_l] = v_basii_4_9();
        v_p = v_p();
    end
    
    if(nargin == 0)
        phi = size(v_p,1);
    end        
    
    if(nargin == 1 && isempty(state))
        phi = v_p;%this is here for my own policy_function
    end
    
    if(nargin == 1 && ~isempty(state))
        phi = v_i(v_l(state));%this is here for my own policy_function
    end
    
    if(nargin==2)
        phi = v_p(:,v_i(v_l(huge_trans_post(state, a_m(:,action), true))));
    end
    
    if(nargin > 2)
        
        width = para;
        
        state_feature=v_p(:,v_i(v_l(huge_trans_post(state, a_m(:,action), true))));
                                
        if(size(state_feature,2) == 1)
            phi = exp(-vecnorm(state_feature-dic_data').^2/width^2)';
        else
            phi = cell2mat(arrayfun(@(c)exp(-vecnorm(state_feature(:,c)-dic_data').^2/para(1)^2)', 1:size(state_feature,2), 'UniformOutput', false));
        end
    end
end