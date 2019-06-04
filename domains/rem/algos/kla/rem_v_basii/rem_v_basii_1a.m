function [v_l, v_i, v_p] = rem_v_basii_1a()

    n_levels = [2, 30, 2, 30];

    state2levels = {
        @trn_level;
        @pop_level;
        @rec_level;
        @int_level;
    };

    level2features = {
        level2linear(n_levels(1));
        level2linear(n_levels(2));
        level2linear(n_levels(3));
        level2linear(n_levels(4));
    };

    [v_l, v_i, v_p] = basic_basii(n_levels, state2levels, level2features);
    
    function tl = trn_level(states)
        if(size(states,1) < 4) 
            tl = zeros(1, size(states,2));
        else
            last_4 = states(end-3:end,:);

            val_t = (last_4(2,:) == last_4(3,:)) & (last_4(1,:) ~= last_4(4,:));

            tl = bin_levels(val_t, 0, 1, n_levels(1));
        end
    end

    function pl = pop_level(states)
        val_p = sum(states(1:end-2,:) == states(end,:),1)/(size(states,1)/2 - 1);

        pl = bin_levels(val_p, 0, 1, n_levels(2));
    end

    function rl = rec_level(states)

        if(size(states,1) < 4) 
            rl = zeros(1, size(states,2));
        else
            last4 = states(end-3:end,:);    
            val_r = (last4(2,:) == last4(3,:)) & (last4(1,:) == last4(4,:));

            rl = bin_levels(val_r, 0, 1, n_levels(3));
        end
    end

    function il = int_level(states)

        val_i = sum(states(1:2:end-2,:) == states(end-1,:) & states(2:2:end-2,:) == states(end,:), 1)./sum(states(1:2:end-2,:) == states(end-1,:),1);    
        val_i(isnan(val_i)) = 0;

        il = bin_levels(val_i, 0, 1, n_levels(4));
    end
end