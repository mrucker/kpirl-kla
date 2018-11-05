function p_out = huge_paramaters(p_in); persistent paramaters;

    if(nargin == 1)
        paramaters = p_in;
    end

    p_out = paramaters;

end