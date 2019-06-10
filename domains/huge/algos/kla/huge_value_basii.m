function [v_i, v_p] = huge_value_basii()

    parameters = huge_parameters();
    
    [v_i, v_p] = feval(['huge_v_basii_' parameters.v_basii]);

end