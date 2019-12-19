function [v_i, v_p] = huge_value_features_1a()
    n_levels = [3 3 3 3 3 3 3 6];

    states2features = {
        @cursor_l_features;
        @cursor_v_features;
        @cursor_a_features;
        @target_t_features;
    };

    features2levels = {
        bin_continuous( 0,1,n_levels(1));
        bin_continuous( 0,1,n_levels(2));
        bin_continuous(-1,1,n_levels(3));
        bin_continuous(-1,1,n_levels(4));
        bin_continuous(-1,1,n_levels(5));
        bin_continuous(-1,1,n_levels(6));
          bin_discrete( 1,  n_levels(7));
          bin_discrete( 0,  n_levels(8));
    };

    levels2features = {
        level2linear(n_levels(1));
        level2linear(n_levels(2));
        level2linear(n_levels(3));
        level2linear(n_levels(4));
        level2linear(n_levels(5));
        level2linear(n_levels(6));
        level2onehot(n_levels(7));
        level2linear(n_levels(8));
    };

    [v_i, v_p] = multi_feature(n_levels, states2features, features2levels, levels2features);

    function l = cursor_l_features(states)
        l = states(1:2,:) ./ states(9:10,:);
    end

    function v = cursor_v_features(states)
        v = states(3:4,:) / 75;
    end

    function a = cursor_a_features(states)
        a = states(5:6,:) / 75;
    end

    function t = target_t_features(states)
        r2 = states(11, 1).^2;

        [cd, pd] = distance_features(states);

        ct = cd <= r2;
        pt = pd <= r2;
        nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

        enter_target = any(ct&(~pt|nt),1);
        leave_target = any(~ct&pt     ,1);

        n_approaching = sum(cd < pd,1);
        i_enter_state = (1:3) * [(enter_target); (~enter_target & ~leave_target); (~enter_target & leave_target)];
        
        t = [ i_enter_state; n_approaching ];
    end
end

function [cd, pd] = distance_features(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);   
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    dtp = dot(tp,tp,1);
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);

    cd = dcp+dtp'-2*(tp'*cp);
    pd = dpp+dtp'-2*(tp'*pp);
end