function f = huge_reward_features()

    f = @feature_rollup;

end

function f = feature_rollup(states)

    if(iscell(states))
        f = cell2mat(cellfun(@(s) {feature_rollup(s)}, states));
    else
        touched = any(touched_targets(states));

        f = [
            cursor_x_features(states);
            cursor_y_features(states);
            cursor_v_features(states);
            cursor_a_features(states);
            cursor_d_features(states);
        ];

        f = [f .* one_or_nan(touched); one_or_nan(~touched)];
    end

    
end

function x = cursor_x_features(states)
    x = states(1,:) ./ states(9,:);
end

function y = cursor_y_features(states)
    y = states(2,:) ./ states(10,:);
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

function i = one_or_nan(logicals)
    i     = double(logicals);
    i(~i) = nan;
end