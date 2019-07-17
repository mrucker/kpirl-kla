function [v_i, v_p] = huge_value_basis()

    parameters = huge_parameters();
    
    [v_i, v_p] = feval(['huge_value_basis_' parameters.v_basis]);

end