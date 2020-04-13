function s2f = rem_features(func)

    params = rem_parameters();
    
    if(strcmp(func, 'reward'))
        s2f = rem_reward_features();
    elseif(strcmp(func, 'value') && params.v_feats == 0)
        s2f = @(states) ones(1, size(states,2));
    elseif(strcmp(func, 'value'))
        s2f = feval(['rem_value_features_' num2str(params.v_feats)]);
    end
end