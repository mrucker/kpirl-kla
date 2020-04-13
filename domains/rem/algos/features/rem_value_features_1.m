function s2f = rem_value_features_1()

    s2f = @states2features;

end

function f = states2features(states)
    f = [
        transitivity(states);
        popularity(states);
        reciprocity(states);
        intransitivity(states);
    ];
end

function f = transitivity(states)
    if(size(states,1) < 4) 
        f = zeros(1, size(states,2));
    else
        f = double((states(end-2,:) == states(end-1,:)) & (states(end-3,:) ~= states(end,:)));
    end
end

function f = popularity(states)
    f = sum(states(1:end-2,:) == states(end,:),1)/(size(states,1)/2 - 1);
end

function f = reciprocity(states)

    if(size(states,1) < 4) 
        f = zeros(1, size(states,2));
    else
        f = double((states(end-2,:) == states(end-1,:)) & (states(end-3,:) == states(end,:)));
    end
end

function f = intransitivity(states)
    f = sum(states(1:2:end-2,:) == states(end-1,:) & states(2:2:end-2,:) == states(end,:), 1)./sum(states(1:2:end-2,:) == states(end-1,:),1);
    f(isnan(f)) = 0;
end