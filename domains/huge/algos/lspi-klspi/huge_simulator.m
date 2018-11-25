function [nextstate, reward, absorb] = huge_simulator(state, action); global R; persistent t_b s_1;

    if(isempty(t_b))
        [~,~,t_b] = huge_transitions();
    end
    
    if(isempty(s_1))
        s_1 = huge_random();
    end

    if(nargin==0)
        nextstate = s_1();
        reward    = 0;
        absorb    = 0;
    end
        
    if(nargin==1)
        nextstate = state;
        reward    = 0;
        absorb    = 0;
    end

    if(nargin==2)        
        nextstate = t_b(state, action);
        reward    = R(state);
        absorb    = 0;
    end
end