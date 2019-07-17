function [v_i, v_p] = rem_value_basis()

    parameters = rem_parameters();
    
    [v_i, v_p] = feval(['rem_v_basis_' parameters.v_basis]);

end