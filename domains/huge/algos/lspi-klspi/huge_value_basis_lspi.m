function phi = huge_value_basis_lspi(state, actions); persistent t_d v_i v_p; 

    if(isempty(t_d))
        [t_d] = huge_transitions();
    end

    if(isempty(v_p))
        [parameters] = huge_parameters();
        [v_i, v_p  ] = huge_value_basis();

        v_p = parameters.transform(v_p(1:v_i()));
    end

    if(nargin == 0)
        phi = size(v_p,1);
    end

    if(nargin==2)
        phi = v_p(:,v_i(t_d(state, actions)))';
    end
end