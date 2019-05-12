function [v_i, v_p] = rem_value_basii()

    parameters = rem_parameters();
    
    [v_i, v_p] = feval(['rem_v_basii_' parameters.v_basii]);

end