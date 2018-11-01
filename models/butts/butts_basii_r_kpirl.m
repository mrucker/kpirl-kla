function [r_i, r_p, r_b, r_l] = butts_basii_r_kpirl()

    r_I = I(LEVELS_N());

    r_p = r_perms();
    r_i = @(states) 1 + r_I'*(statesfun(@r_levels, states)-1);
    r_b = @(states) r_feats(statesfun(@r_levels, states));
    r_l = @(states) statesfun(@r_levels, states);
    
end

function rl = r_levels(states)

    trn = trn_levels(states);
    pop = pop_levels(states);
    rec = rec_levels(states);
    int = int_levels(states);

    rl = vertcat(trn, pop, rec, int);
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

    t = 1:LEVELS_N(1);
    p = 1:LEVELS_N(2);
    r = 1:LEVELS_N(3);
    i = 1:LEVELS_N(4);

    t_i = 1:size(t,2);
    p_i = 1:size(p,2);
    r_i = 1:size(r,2);
    i_i = 1:size(i,2);
    
    [i_c, r_c, p_c, t_c] = ndgrid(i_i, r_i, p_i, t_i);

    rp = r_feats([
        t(:,t_c(:));
        p(:,p_c(:));
        r(:,r_c(:));
        i(:,i_c(:));
    ]);
end

function tl = trn_levels(states)

    last4 = states(end-3:end,:);
    
    val_t = (last4(2,:) == last4(3,:)) & (last4(1,:) ~= last4(4,:));
    
    tl = bin_levels(val_t, LEVELS_B(1), 1, LEVELS_N(1));
end

function pl = pop_levels(states)
    val_p = sum(states(1:end-2,:) == states(end,:),1)/(size(states,1)/2 - 1);
    
    pl = bin_levels(val_p, LEVELS_B(2), 1, LEVELS_N(2));
end

function rl = rec_levels(states)

    last4 = states(end-3:end,:);    
    val_r = (last4(2,:) == last4(3,:)) & (last4(1,:) == last4(4,:));
    
    rl = bin_levels(val_r, LEVELS_B(3), 1, LEVELS_N(3));
end

function il = int_levels(states)

    val_i = sum(states(1:2:end-2,:) == states(end-1,:) && states(2:2:end-2,:) == states(end,:))/sum(states(1:2:end-2,:) == states(end-1,:));
    
    il = bin_levels(val_i, LEVELS_B(4), 1, LEVELS_N(4));
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

function l = LEVELS_N(i) 
    l = [2, 30, 2, 30];
    
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