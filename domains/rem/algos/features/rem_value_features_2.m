function s2f = rem_value_features_2()
    s2f = @states2features;
end

function f = states2features(states)
    f = [
        transitivity(states);
        reciprocity(states);
    ];
end

function f = transitivity(states)
    if(size(states,1) < 4) 
        f = zeros(1, size(states,2));
    else
        f = double((states(end-2,:) == states(end-1,:)) & (states(end-3,:) ~= states(end,:)));
    end
end

function f = reciprocity(states)
    if(size(states,1) < 4) 
        f = zeros(1, size(states,2));
    else
        f = double((states(end-2,:) == states(end-1,:)) & (states(end-3,:) == states(end,:)));
    end
end
