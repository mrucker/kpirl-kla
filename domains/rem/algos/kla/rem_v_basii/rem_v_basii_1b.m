function [v_i, v_p] = rem_v_basii_1b()

    v_I = I(LEVELS_N());

    v_p = perms();
    v_i = @(states) 1 + v_I'*(statesfun(@levels, states));

end

function rl = levels(states)

    trn = trn_levels(states);
    rec = rec_levels(states);

    rl = vertcat(trn, rec);
end

function rf = feats(levels)

    lvl_to_d = @(val, den     ) val/den;
    %lvl_to_e = @(val, cnt     ) double(1:cnt == val')';
    %lvl_to_r = @(val, den, trn) (val~=-1) .* [cos(trn*pi/den + val*pi/den); sin(trn*pi/den + val*pi/den)];

    assert(all(levels(:)>=1), 'bad levels');    

    t_l = levels(1,:);
    r_l = levels(2,:);

    rf = [
        lvl_to_d(t_l, LEVELS_N(1)-1)
        lvl_to_d(r_l, LEVELS_N(2)-1)
    ];

end

function rp = perms()

    t = 1:LEVELS_N(1);
    r = 1:LEVELS_N(2);

    t_i = 1:size(t,2);
    r_i = 1:size(r,2);
    
    [r_c, t_c] = ndgrid(r_i, t_i);

    rp = feats([
        t(:,t_c(:));
        r(:,r_c(:));
    ]);
end

function tl = trn_levels(states)

    if(size(states,1) < 4) 
        tl = zeros(1, size(states,2));
    else
        last_4 = states(end-3:end,:);

        val_t = (last_4(2,:) == last_4(3,:)) & (last_4(1,:) ~= last_4(4,:));

        tl = bin_levels(val_t, 0, 1, LEVELS_N(1));
    end
end

function rl = rec_levels(states)

    if(size(states,1) < 4) 
        rl = zeros(1, size(states,2));
    else
        last4 = states(end-3:end,:);    
        val_r = (last4(2,:) == last4(3,:)) & (last4(1,:) == last4(4,:));

        rl = bin_levels(val_r, 0, 1, LEVELS_N(2));
    end
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

function bl = bin_levels(val, min_val, max_val, bins)

    %fastest
    val = max([val;min_val*ones(1,size(val,2))],[], 1);
    val = min([val;max_val*ones(1,size(val,2))],[], 1);
    bl  = floor((val-min_val)*(bins-1)/(max_val-min_val));

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
    l = [2, 2];
    
    if(nargin ~= 0)
        l = l(i);
    end
end
%% Probably don't need to change %%