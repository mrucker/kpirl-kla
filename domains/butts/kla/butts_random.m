function [state] = butts_random()

    [paramaters] = butts_paramaters();
    [a_v, a_m  ] = butts_actions();
    
    a_n   = 2+randi(paramaters.max_rand);    
    state = zeros(2*a_n,1);
    
    
    for i = 1:a_n
        
        if i == 1
            actions = a_m(:,randi(size(a_m,2)));
        else
            actions = a_v(state(1:(i-1)*2)); %is this right????
        end
        
        state(2*(i-1) + (1:2)) = actions(:,randi(size(actions,2)));
    end
end