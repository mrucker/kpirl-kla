function [state] = butts_random()

    paramaters = butts_paramaters();
    smp_length = randi(paramaters.max_rand);
    
    state = zeros(2*smp_length,1);
    af    = butts_states_action();
    
    for i = 1:smp_length
        
        if i == 1
            actions = af([]);
        else
            actions = af(state(1:(i-1)*2));
        end
        
        state(2*i-1:2*i) = actions(randi(size(actions,2)));
    end
end