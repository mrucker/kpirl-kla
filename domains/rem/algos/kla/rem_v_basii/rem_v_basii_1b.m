function [v_l, v_i, v_f] = rem_v_basii_1b()

    n_levels = [2, 2];

    state2levels = {
        @trn_level;
        @rec_level;
    };

    level2features = {
        level2linear(n_levels(1));
        level2linear(n_levels(2));
    };

    function tl = trn_level(states)

        if(size(states,1) < 4) 
            tl = zeros(1, size(states,2));
        else
            last_4 = states(end-3:end,:);

            val_t = (last_4(2,:) == last_4(3,:)) & (last_4(1,:) ~= last_4(4,:));

            tl = bin_levels(val_t, 0, 1, n_levels(1));
        end
    end

    function rl = rec_level(states)

        if(size(states,1) < 4) 
            rl = zeros(1, size(states,2));
        else
            last4 = states(end-3:end,:);    
            val_r = (last4(2,:) == last4(3,:)) & (last4(1,:) == last4(4,:));

            rl = bin_levels(val_r, 0, 1, n_levels(2));
        end
    end

    [v_l, v_i, v_f] = basic_basii(n_levels, state2levels, level2features);
end