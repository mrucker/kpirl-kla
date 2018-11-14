function [v_i, v_p, v_l] = rem_value_basii()

    paramaters = rem_paramaters();
    
    [v_i, v_p, v_l] = feval(['rem_v_basii_' paramaters.v_basii]);

end