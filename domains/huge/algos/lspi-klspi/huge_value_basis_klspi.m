function phi = huge_value_basis_klspi(state, actions, exemplars); persistent t_d v_p;

    if(isempty(t_d))
        [t_d] = huge_transitions();
    end

    if(isempty(v_p))        
        [~, v_p] = huge_value_basis();
    end
    
    if(nargin==2)
        phi = v_p(t_d(state, actions));
    end

    if(nargin == 3)
        parameters = huge_parameters();
        
        phi = parameters.kernel(v_p(t_d(state, actions)), exemplars')';        
    end
end