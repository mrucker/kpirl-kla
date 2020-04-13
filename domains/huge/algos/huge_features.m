function [s2f] = huge_features(func)

    params = huge_parameters();

    if(strcmp(func,'reward'))
        [s2f] = huge_reward_features();
    end
    
    if(strcmp(func,'value'))        
        if params.v_feats == 0
            [s2f] = @(post) 1;
        else
            [s2f] = huge_value_features();
        end
    end
    
end