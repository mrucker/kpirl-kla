function [v_i, v_p] = rem_value_basii()

    paramaters = rem_paramaters();
    
    [v_i, v_p] = feval(['rem_v_basii_' paramaters.v_basii]);

end