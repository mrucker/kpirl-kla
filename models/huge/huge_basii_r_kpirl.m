function [r_i, r_p, r_b, r_l] = huge_basii_r()

    r_I = I([LEVELS_N(), 1]);

    r_p = r_perms();
    r_i = @(states) 1 + r_I'*(statesfun(@r_levels, states)-1);
    r_b = @(states) r_feats(statesfun(@r_levels, states));
    r_l = @(states) statesfun(@r_levels, states);
end

function rl = r_levels(states)

    tou = is_touching_target(states);

    if ~any(tou(:))
        rl = ones(6, size(states,2));
    else
        tou = keep_first_touch_only(tou);

        lox = dot(target_x_levels(states), tou) + ~any(tou, 1);
        loy = dot(target_y_levels(states), tou) + ~any(tou, 1);
        vel = dot(cursor_v_levels(states), tou) + ~any(tou, 1);
        acc = dot(cursor_a_levels(states), tou) + ~any(tou, 1);
        dir = dot(cursor_d_levels(states), tou) + ~any(tou, 1);
        tou = 1*(~any(tou,1)) + 2*(any(tou,1));

        rl = vertcat(lox, loy, vel, acc, dir, tou);
    end
end

function rf = r_feats(levels)

    assert(all(levels(:)>0), 'bad levels');

    val_to_rad = @(val, den, trn) (val~=-1) .* [cos(trn*pi/den + val*pi/den); sin(trn*pi/den + val*pi/den)];

    is_touched = (levels(end,:) == 2);

    x_l = levels(1,:) .* is_touched;
    y_l = levels(2,:) .* is_touched;
    v_l = levels(3,:) .* is_touched;
    a_l = levels(4,:) .* is_touched;
    d_l = levels(5,:) .* is_touched;

    rf = [
        val_to_rad(x_l-1, LEVELS_N(1)-1, 0.0) * 1/01;
        val_to_rad(y_l-1, LEVELS_N(2)-1, 0.0) * 1/01;
        val_to_rad(v_l-1, LEVELS_N(3)*2, 0.0) * 1/01;
        val_to_rad(a_l-1, LEVELS_N(4)*2, 0.0) * 1/01;
        val_to_rad(d_l-1, LEVELS_N(5)/2, 4.5) * 6/10;
        4 * (levels(end,:) == 1);
    ];

end

function rp = r_perms()

    x = 1:LEVELS_N(1);
    y = 1:LEVELS_N(2);
    v = 1:LEVELS_N(3);
    a = 1:LEVELS_N(4);
    d = 1:LEVELS_N(5);
    z = 2;

    x_i = 1:size(x,2);
    y_i = 1:size(y,2);
    v_i = 1:size(v,2);
    a_i = 1:size(a,2);
    d_i = 1:size(d,2);
    z_i = 1:size(z,2);

    [z_c, d_c, a_c, v_c, y_c, x_c] = ndgrid(z_i, d_i, a_i, v_i, y_i, x_i);

    touch_0 = [zeros(10,1); 4];
    touch_1 = r_feats([
        x(:,x_c(:));
        y(:,y_c(:));
        v(:,v_c(:));
        a(:,a_c(:));
        d(:,d_c(:));
        z(:,z_c(:));
    ]);

    rp = horzcat(touch_0, touch_1);

end

function tx = target_x_levels(states)

    val_x = states(12:3:end,1)/states(09,1);
    lvl_x = bin_levels(val_x, LEVELS_B(1), 1, LEVELS_N(1));

    tx = repmat(lvl_x, 1, size(states,2));
end

function ty = target_y_levels(states)

    val_y = states(13:3:end,1)/states(10,1);
    lvl_y = bin_levels(val_y, LEVELS_B(2), 1, LEVELS_N(2));

    ty = repmat(lvl_y, 1, size(states,2));
end

function cv = cursor_v_levels(states)

    trg_n = (size(states,1) - 11)/3;

    val_v = vecnorm(states(3:4,:));
    lvl_v = bin_levels(val_v, LEVELS_B(3), 1, LEVELS_N(3));

    cv = repmat(lvl_v, trg_n, 1);
end

function ca = cursor_a_levels(states)

    trg_n = (size(states,1) - 11)/3;

    val_a = vecnorm(states(5:6,:));
    lvl_a = bin_levels(val_a, LEVELS_B(4), 1, LEVELS_N(4));

    ca = repmat(lvl_a, trg_n, 1);
end

function cd = cursor_d_levels(states)

    trg_n = (size(states,1) - 11)/3;

    val_d = atan2(-states(4,:), states(3,:)) + pi;
    lvl_d = bin_levels(val_d, LEVELS_B(5), 1, LEVELS_N(5));

    cd = repmat(lvl_d, trg_n, 1);
end

%% Probably don't need to change %%
function i = I(L)
    L = [L, 1]; %add one for easier computing
    i = arrayfun(@(l) prod(L(l:end)), 2:numel(L))';
end

function sf = statesfun(func, states)
    if iscell(states)
        sf = cell2mat(cellfun(func, states, 'UniformOutput',false));
    else
        sf = func(states);
    end
end

function bl = bin_levels(vals, bin_size, min_level, max_level)

    %fastest
    bl = ceil(vals/bin_size);
    bl = max (bl, min_level);
    bl = min (bl, max_level);

    %%second fastest
    %bl = min(ceil((vals+.01)/bin_s), bin_n);
    %%second fastest

    %%third fastest
    %[~, bl] = max(vals <= [1:bin_n-1, inf]' * bin_s);
    %%third fastest

    %%fourth fastest (close 3rd)
    %r_bins = [   1:bin_n-1, inf]' * bin_s;
    %l_bins = [0, 1:bin_n-1     ]' * bin_s;

    %bin_ident = l_bins <= vals & vals < r_bins;
    %bl = (1:bin_n) * bin_ident;
    %%fourth fastest (close 3rd)

    %%fifth fastest
    %bins = (1:bin_n-1) * bin_s;
    %bl = discretize(vals,[0,bins,inf]);
    %%fifth fastest
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

function l = LEVELS_N(i) 
    l = [3, 3, 8, 6, 8];
    
    if(nargin ~= 0)
        l = l(i);
    end
end

function l = LEVELS_B(i)
    l = [1/LEVELS_N(1), 1/LEVELS_N(2), 6, 10, 2*pi/LEVELS_N(5)];

    if(nargin ~= 0)
        l = l(i);
    end
end
%% Probably don't need to change %%