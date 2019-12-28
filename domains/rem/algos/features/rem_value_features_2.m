function [v_p, v_i] = rem_value_features_2()

    n_levels = [2, 2];

    state2feature = {
        @transitivity;
        @reciprocity;
    };
    
    feature2level = {
          bin_discrete(0  ,n_levels(1));
          bin_discrete(0  ,n_levels(2));
    };

    level2feature = {
        level2linear(n_levels(1));
        level2linear(n_levels(2));
    };

    [v_p, v_i] = multi_feature(n_levels, state2feature, feature2level, level2feature);
    
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
end