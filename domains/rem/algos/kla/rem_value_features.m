function [v_i, v_p] = rem_value_features()

    parameters = rem_parameters();
    
    [v_i, v_p] = feval(['rem_value_features_' parameters.v_basis]);

end