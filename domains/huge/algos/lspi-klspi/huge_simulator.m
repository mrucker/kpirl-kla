function [nextstate, absorb] = huge_simulator(state, action); persistent t_b s_1;

    if(isempty(t_b))
        [~,~,t_b] = huge_transitions();
    end
    
    if(isempty(s_1))
        s_1 = huge_initiator();
    end

    if(nargin==0)
        nextstate = s_1();
        absorb    = 0;
    end

    if(nargin==2)        
        nextstate = t_b(state, action);
        absorb    = 0;
    end
end