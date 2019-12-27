function [v_p, v_i] = krand_value_features()

    parameters = krand_parameters();
    
    [v_p, v_i] = feval(['krand_value_features_' parameters.v_feats]);

end