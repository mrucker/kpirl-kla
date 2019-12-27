function [nextstate, absorb] = huge_simulator(state, action); persistent t_s;
    
    if(isempty(t_s))
        t_s = huge_transitions();
    end
    
    if(nargin==0)
        nextstate = t_s();
        absorb    = 0;
    end

    if(nargin==2)
        nextstate = t_s(state, action);
        absorb    = 0;
    end
end