function state2basis = huge_value_basis_klspi()

    [t_d       ] = huge_transitions();
    [~, v_p  ] = huge_value_basis();
    [parameters] = huge_parameters();
    
    kernel = @parameters.kernel;

    state2basis = @state2basis_closure;
    
    function phi = state2basis_closure(state, actions, exemplars)
        if(nargin == 2)
            phi = v_p(t_d(state, actions))';
        end

        if(nargin == 3)
            phi = kernel(v_p(t_d(state, actions)), exemplars');        
        end
    end
end