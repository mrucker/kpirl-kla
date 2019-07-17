function [v_l, v_i, v_p] = single_basis()

    v_l = @states2levels;
    v_p = @levels2phis;
    v_i = @levels2indexes;

    function levels = states2levels(~)
        if nargin == 0
            levels = 1;
        else
            levels = 1;
        end
    end

    function phis = levels2phis(~)
        phis = 1;
    end

    function indexes = levels2indexes(~)
        indexes = 1;
    end
end