function [f] = huge_value_features()
    f = @(states) [
        cursor_l_features(states);
        cursor_v_features(states);
        cursor_a_features(states);
        target_t_features(states);
    ];
end

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