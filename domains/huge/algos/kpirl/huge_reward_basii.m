function [r_i, r_p] = huge_reward_basii()

    partitions = {[3, 3, 8, 6, 8], 1};
    
    state2levels = {
        @level_rollup;
    };

    level2features = {
        level2circle(partitions{1}(1)-1, 0  );
        level2circle(partitions{1}(2)-1, 0  );
        level2circle(partitions{1}(3)*2, 0  );
        level2circle(partitions{1}(4)*2, 0  );
        level2circle(partitions{1}(5)/2, 4.5); % removed `* 6/10`;
        level2scalar(4);
    };

    [r_i, r_p] = basic_basii(partitions, state2levels, level2features);
    
    function ls = level_rollup(states)

        tou = is_touching_target(states);

        if ~any(tou(:))
            ls = vertcat(zeros(5, size(states,2)), ones(1,size(states,2))) ;
        else
            tou = keep_first_touch_only(tou);

            lox = dot(target_x_levels(states), tou);
            loy = dot(target_y_levels(states), tou);
            vel = dot(cursor_v_levels(states), tou);
            acc = dot(cursor_a_levels(states), tou);
            dir = dot(cursor_d_levels(states), tou);
            tou = ~any(tou,1);

            ls = vertcat(lox, loy, vel, acc, dir, tou);
        end
    end

    function tx = target_x_levels(states)

        lvl_x = bin_levels(states(12:3:end,1)', 0, states(9,1), partitions{1}(1))';

        tx = repmat(lvl_x, 1, size(states,2));
    end

    function ty = target_y_levels(states)

        lvl_y = bin_levels(states(13:3:end,1)', 0, states(10,1), partitions{1}(2))';

        ty = repmat(lvl_y, 1, size(states,2));
    end

    function cv = cursor_v_levels(states)

        trg_n = (size(states,1) - 11)/3;

        lvl_v = bin_levels(vecnorm(states(3:4,:))', 0, 7, partitions{1}(3))';

        cv = repmat(lvl_v, trg_n, 1);
    end

    function ca = cursor_a_levels(states)

        trg_n = (size(states,1) - 11)/3;

        lvl_a = bin_levels(vecnorm(states(5:6,:))', 0, 5, partitions{1}(4))';

        ca = repmat(lvl_a, trg_n, 1);
    end

    function cd = cursor_d_levels(states)

        trg_n = (size(states,1) - 11)/3;

        val_d = atan2(-states(4,:), states(3,:)) + pi;
        lvl_d = bin_levels(val_d', 0, 2*pi, partitions{1}(5))';

        cd = repmat(lvl_d, trg_n, 1);
    end
end

function [cd, pd] = distance_from_targets(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    dtp = dot(tp,tp,1);
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);

    cd = dcp+dtp'-2*(tp'*cp);
    pd = dpp+dtp'-2*(tp'*pp);
end

function t = is_touching_target(states)
    r2 = states(11, 1).^2;

    [cd, pd] = distance_from_targets(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    t = ct&(~pt|nt);
end

function t = keep_first_touch_only(touches)

    s = size(touches);
    c = 1:size(touches,2);

    [v,r] = max(touches,[],1);

    t = zeros(s);
    i = sub2ind(s, r(v~=0), c(v~=0));

    t(i) = 1;
end