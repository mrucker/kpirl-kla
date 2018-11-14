function [v_i, v_p, v_l] = huge_value_basii()

    paramaters = huge_paramaters();
    
    [v_i, v_p, v_l] = feval(['huge_v_basii_' paramaters.v_basii]);

end