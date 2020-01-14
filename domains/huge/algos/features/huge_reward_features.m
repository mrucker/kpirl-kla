function [r_p, r_i] = huge_reward_features()

    partitions = {[3, 3, 8, 6, 8], 1};
    
    state2feature = {
        @feature_rollup;
    };

    feature2level = {
        bin_continuous(0,    1, partitions{1}(1));
        bin_continuous(0,    1, partitions{1}(2));
        bin_continuous(0,   48, partitions{1}(3));
        bin_continuous(0,   60, partitions{1}(4));
        bin_continuous(0, 2*pi, partitions{1}(5));
          bin_discrete(1,       partitions{2}(1));
    };

    level2feature = {
        level2circle(partitions{1}(1)-1, 0  );
        level2circle(partitions{1}(2)-1, 0  );
        level2circle(partitions{1}(3)*2, 0  );
        level2circle(partitions{1}(4)*2, 0  );
        level2circle(partitions{1}(5)/2, 4.5);
        level2scalar(4);
    };

    [r_p, r_i] = multi_feature(partitions, state2feature, feature2level, level2feature);  
end

function f = feature_rollup(states)
    touches = touched_targets(states);
    i_first = i_first_touch(touches);

    if all(isnan(i_first))
        f = vertcat(nan(5, size(states,2)), ones(1,size(states,2))) ;
    else
        f = [
            index_dim1_else_nan(target_x_features(states), i_first);
            index_dim1_else_nan(target_y_features(states), i_first);
            index_nan0_else_nan(cursor_v_features(states), i_first);
            index_nan0_else_nan(cursor_a_features(states), i_first);
            index_nan0_else_nan(cursor_d_features(states), i_first);
            index_nan1_else_nan(   double(isnan(i_first)), i_first);
        ];
    end
end

function x = target_x_features(states)
    x = states(12:3:end,:) ./ states(9,:);
end

function y = target_y_features(states)
    y = states(13:3:end,1) ./ states(10,:);
end

function v = cursor_v_features(states)
    v = vecnorm(states(3:4,:));
end

function a = cursor_a_features(states)
    a = vecnorm(states(5:6,:));
end

function d = cursor_d_features(states)
    d = atan2(-states(4,:), -states(3,:)) + pi;
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

function t = touched_targets(states)
    r2 = states(11, 1).^2;

    [cd, pd] = distance_from_targets(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    t = ct&(~pt|nt);
end

function i = i_first_touch(touches)

    if isempty(touches)
        i = nan;
    else
        [v, i] = max(touches,[],1);
        i(v==0) = nan;
    end
end

function v = index_dim1_else_nan(A, i_r)
    [n_r, n_c] = size(A);
    
    i_c = find(~isnan(i_r));
    i_r = i_r(i_c);
    
    v = nan(1,n_c);
    
    v(i_c) = A(sub2ind([n_r, n_c], i_r, i_c));
end

function v = index_nan0_else_nan(a, i)
    n = size(a,2);
    i = find(~isnan(i));

    v    = nan(1,n);
    v(i) = a(i);
end

function v = index_nan1_else_nan(a, i)
    n = size(a,2);
    i = find(isnan(i));

    v    = nan(1,n);
    v(i) = a(i);
end