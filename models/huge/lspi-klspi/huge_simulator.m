function [nextstate, reward, absorb] = huge_simulator(state, action); global R INIT_STATES; persistent actions;

    if(isempty(actions))
        s_a = s_act_4_2();
        actions = s_a([]);
    end

    if(nargin==0)
        nextstate = INIT_STATES{randi(numel(INIT_STATES))};%this should be a random state in theory
        reward    = 0;
        absorb    = 0;
    end
        
    if(nargin==1)
        nextstate = state;
        reward    = 0;
        absorb    = 0;
    end

    if(nargin==2)        
        nextstate = huge_trans_pre(state, actions(:,action), true);
        reward    = R(state);
        absorb    = 0;
    end
end