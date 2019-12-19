function state2features = huge_value_features_lspi()

    [t_p   ] = huge_transitions();
    [~, v_p] = huge_value_features();
        
    state2features = @(state, actions) v_p(t_p(state, actions));
end