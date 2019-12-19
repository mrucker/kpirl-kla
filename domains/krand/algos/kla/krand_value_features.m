function [v_i, v_p] = krand_value_features()

    parameters = krand_parameters();
    
    [v_i, v_p] = feval(['krand_value_features_' parameters.v_feats]);

end