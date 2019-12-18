function state2basis = huge_value_basis_lspi()

    [t_d       ] = huge_transitions();
    [v_i, v_p  ] = huge_value_features();
    
    v_p = v_p(1:v_i());
    
    state2basis = @state2basis_closure;
    
    function phi = state2basis_closure(state, actions)
        phi = v_p(:,v_i(t_d(state, actions)));
    end
end