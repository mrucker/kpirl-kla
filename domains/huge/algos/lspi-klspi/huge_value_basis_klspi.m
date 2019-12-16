function [state2basis, basis2simil] = huge_value_basis_klspi()

    [t_d       ] = huge_transitions();
    [~, v_p    ] = huge_value_features();
    [parameters] = huge_parameters();

    kernel = @parameters.kernel;

    state2basis = @state2basis_closure;
    basis2simil = @basis2simil_closure;

    function phi = state2basis_closure(state, actions)
        phi = v_p(t_d(state, actions))';
    end

    function phi = basis2simil_closure(basis, exemplars)
        phi = kernel(basis', exemplars');
    end
end