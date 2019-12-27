function [v_p, v_i] = rem_value_features()

    parameters = rem_parameters();
    
    [v_p, v_i] = feval(['rem_value_features_' parameters.v_feats]);

end