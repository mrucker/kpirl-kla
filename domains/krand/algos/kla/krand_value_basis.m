function [v_i, v_p] = krand_value_basis()

    parameters = krand_parameters();
    
    [v_i, v_p] = feval(['krand_v_basis_' parameters.v_basis]);

end