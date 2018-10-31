function [v_i, v_p, v_b, v_l] = huge_basii_v()
    
    v_I = I(LEVELS_N());

    v_p = @v_perms;
    v_i = @(levels) 1 + v_I'*(levels-1);
    v_b = @(levels) v_feats(levels);
    v_l = @(states) statesfun(states);
end

function vl = v_levels(states)

    l_p = cursor_p_levels(states);
    l_v = cursor_v_levels(states);
    l_a = cursor_a_levels(states);
    l_t = target_t_levels(states);

    vl = vertcat(l_p, l_v, l_a, l_t);
end

function [vf] = v_feats(levels)

    val_to_d = @(val,den) val/den;
    val_to_e = @(val,  n) double(1:n == val')';

    vf = [
        val_to_d(levels(1,:)-1, LEVELS_N(1)-1);
        val_to_d(levels(2,:)-1, LEVELS_N(2)-1);
        val_to_d(levels(3,:)-1, LEVELS_N(3)-1);
        val_to_d(levels(4,:)-1, LEVELS_N(4)-1);
        val_to_d(levels(5,:)-1, LEVELS_N(5)-1);
        val_to_d(levels(6,:)-1, LEVELS_N(6)-1);
        val_to_e(levels(7,:)-0, LEVELS_N(7)-0);
        val_to_d(levels(8,:)-1, LEVELS_N(8)-1);
    ];

end

function vp = v_perms()

    p_x_i = 1:LEVELS_N(1);
    p_y_i = 1:LEVELS_N(2);
    v_x_i = 1:LEVELS_N(3);
    v_y_i = 1:LEVELS_N(4);
    a_x_i = 1:LEVELS_N(5);
    a_y_i = 1:LEVELS_N(6);
    t_t_i = 1:LEVELS_N(7);
    t_n_i = 1:LEVELS_N(8);

    [t_n_c, t_t_c, a_d_c, a_m_c, v_d_c, v_m_c, p_y_c, p_x_c] = ndgrid(t_n_i, t_t_i, a_y_i, a_x_i, v_y_i, v_x_i, p_y_i, p_x_i);

    vp = v_feats([
        p_x_i(:,p_x_c(:));
        p_y_i(:,p_y_c(:));
        v_x_i(:,v_m_c(:));
        v_y_i(:,v_d_c(:));
        a_x_i(:,a_m_c(:));
        a_y_i(:,a_d_c(:));
        t_t_i(:,t_t_c(:));
        t_n_i(:,t_n_c(:));
    ]);
end

function lp = cursor_p_levels(states)
    LEVELS_N_x = LEVELS_N(1);
    LEVELS_N_y = LEVELS_N(2);

    l_x = bin_levels(states(1,:), states(9,1)/LEVELS_N_x, 1, LEVELS_N_x);
    l_y = bin_levels(states(2,:), states(9,1)/LEVELS_N_y, 1, LEVELS_N_y);

    lp = [l_x;l_y];
end

function lv = cursor_v_levels(states)
    LEVELS_N_x = LEVELS_N(3);
    LEVELS_N_y = LEVELS_N(4);
    
    bin_x_size = 50;
    bin_y_size = 50;

    v_x = states(3,:) + bin_x_size*LEVELS_N_x/2;
    v_y = states(4,:) + bin_y_size*LEVELS_N_y/2;

    l_x = bin_levels(v_x, bin_x_size, 1, LEVELS_N_x);
    l_y = bin_levels(v_y, bin_y_size, 1, LEVELS_N_y);

    lv = [l_x;l_y];
end

function la = cursor_a_levels(states)
    LEVELS_N_x = LEVELS_N(5);
    LEVELS_N_y = LEVELS_N(6);

    bin_x_size = 50;
    bin_y_size = 50;

    a_x = states(5,:) + bin_x_size*LEVELS_N_x/2;
    a_y = states(6,:) + bin_y_size*LEVELS_N_y/2;

    l_x = bin_levels(a_x, bin_x_size, 1, LEVELS_N_x);
    l_y = bin_levels(a_y, bin_y_size, 1, LEVELS_N_y);

    la = [l_x;l_y];

end

function lt = target_t_levels(states)

    LEVELS_N_t = LEVELS_N(7);
    LEVELS_N_n = LEVELS_N(8);

    r2 = states(11, 1).^2;
    
    [cd, pd] = distance_features(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    enter_target = any(ct&(~pt|nt),1);
    leave_target = any(~ct&pt     ,1);

    approach_n = sum(cd < pd,1);

    tt = (1:LEVELS_N_t) * [ (~enter_target & ~leave_target); (enter_target); (~enter_target & leave_target ); ];
    tn = bin_levels(approach_n, 1, 1, LEVELS_N_n);
    
    lt = [tt; tn];
end

%% Probably don't need to change %%
function v = I(n)
    n = [n, 1]; %add one for easier computing
    v = arrayfun(@(i) prod(n(i:end)), 2:numel(n))';
end

function sf = statesfun(states)
    if iscell(states)
        sf = cell2mat(cellfun(@v_levels, states, 'UniformOutput',false));
    else
        sf = v_levels(states);
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

    %%fourth fastest (close to 3rd)
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

function l = LEVELS_N(i) 
    l = [3 3 3 3 3 3 3 6];
    
    if(nargin ~= 0)
        l = l(i);
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

%% Probably don't need to change %%