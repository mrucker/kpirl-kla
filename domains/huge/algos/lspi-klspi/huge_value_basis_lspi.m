function state2basis = huge_value_basis_lspi()

    [t_d       ] = huge_transitions();
    [v_i, v_p  ] = huge_value_features();
    [parameters] = huge_parameters();
    
    v_p = parameters.transform(v_p(1:v_i()));
    
    state2basis = @state2basis_closure;
    
    function phi = state2basis_closure(state, actions)
        if(nargin == 0)
            phi = size(v_p,1);
        end

        if(nargin==2)
            phi = v_p(:,v_i(t_d(state, actions)))';
        end
    end
end