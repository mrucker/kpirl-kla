function [p, i] = huge_features(func)

    params = huge_parameters();

    if(strcmp(func,'reward'))
        [p, i] = feval('huge_reward_features');
    end
    
    if(strcmp(func,'value'))        
        if params.v_feats == 0
            [p, i] = single_feature();
        else
            [p, i] = feval('huge_value_features');
        end
    end
    
end