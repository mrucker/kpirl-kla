function [v_i, v_p] = krand_value_basii()

    parameters = krand_parameters();
    
    [v_i, v_p] = feval(['krand_v_basii_' parameters.v_basii]);

end