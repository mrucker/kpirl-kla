function [v_i, v_p, v_l] = butts_value_basii()

    paramaters = butts_paramaters();
    
    [v_i, v_p, v_l] = feval(paramaters.v_basii);

end