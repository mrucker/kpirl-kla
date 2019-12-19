function state2features = huge_value_features_lspi()

    [t_d   ] = huge_transitions();
    [~, v_p] = huge_value_features();
        
    state2features = @(state, actions) v_p(t_d(state, actions));
end