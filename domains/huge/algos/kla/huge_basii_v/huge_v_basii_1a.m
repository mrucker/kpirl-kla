function [v_l, v_i, v_p] = huge_v_basii_1a()
    n_levels = [3 3 3 3 3 3 3 6];

    state2levels = {
        @level_rollup
    };

    level2features = {
        level2linear(n_levels(1));
        level2linear(n_levels(2));
        level2linear(n_levels(3));
        level2linear(n_levels(4));
        level2linear(n_levels(5));
        level2linear(n_levels(6));
        level2onehot(n_levels(7));
        level2linear(n_levels(8));
    };

    [v_l, v_i, v_p] = basic_basii(n_levels, state2levels, level2features);
    
    function ll = level_rollup(states)
        l_p = cursor_p_levels(states);
        l_v = cursor_v_levels(states);
        l_a = cursor_a_levels(states);
        l_t = target_t_levels(states);

        ll = vertcat(l_p, l_v, l_a, l_t);
    end
    
    function lp = cursor_p_levels(states)

        l_x = bin_levels(states(1,:), 0, states(9 ,1), n_levels(1));
        l_y = bin_levels(states(2,:), 0, states(10,1), n_levels(2));

        lp = [l_x;l_y];
    end

    function lv = cursor_v_levels(states)

        l_x = bin_levels(states(3,:), -75, 75, n_levels(3));
        l_y = bin_levels(states(4,:), -75, 75, n_levels(4));

        lv = [l_x;l_y];
    end

    function la = cursor_a_levels(states)

        l_x = bin_levels(states(5,:), -75, 75, n_levels(5));
        l_y = bin_levels(states(6,:), -75, 75, n_levels(6));

        la = [l_x;l_y];
    end

    function lt = target_t_levels(states)

        r2 = states(11, 1).^2;

        [cd, pd] = distance_features(states);

        ct = cd <= r2;
        pt = pd <= r2;
        nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

        enter_target = any(ct&(~pt|nt),1);
        leave_target = any(~ct&pt     ,1);

        approach_n = sum(cd < pd,1);

        tt = (1:n_levels(7)) * [ (~enter_target & ~leave_target); (enter_target); (~enter_target & leave_target ); ];
        tn = bin_levels(approach_n, 0, 7, n_levels(8));

        lt = [tt; tn];
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