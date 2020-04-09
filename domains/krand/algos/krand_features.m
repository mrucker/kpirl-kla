function [p, i] = krand_features(func)

    params = krand_parameters();
    
    if(strcmp(func, 'reward'))
        [p, i] = krand_reward_features();
    end
    
    if(strcmp(func, 'value'))
        if(params.v_feats == 0)
            [p, i] = single_feature();
        else
            [p, i] = krand_reward_features();
        end 
    end
end

function [p, i] = krand_reward_features()
    n_levels = [9, 30, 21, 31, 96, 7];

    state2feature = {
        @rail_type;
        @highway_type;
        @highway_maxspeed;
        @building_type;
        @time_of_day_pct;
        @day_of_week;
    };

    feature2level = {
        bin_identity();
        bin_identity();
        bin_continuous(0, 150, n_levels(3));
        bin_identity();
        bin_continuous(0,   1, n_levels(5));
        bin_identity();
    };

    [p, i] = multi_feature(n_levels, state2feature, feature2level);

    function v = rail_type(states)
        v = 1+states.rail_type;
        v(isnan(v)) = 1;
    end

    function v = highway_type(states)
        v = 1+states.hwy_typ;
        v(isnan(v)) = 1;
    end

    function v = highway_maxspeed(states)

         v = states.hwy_maxsp;
         v(isnan(v)) = 0;

    end

    function v = building_type(states)

        v = 1+states.bldg_typ;
        v(isnan(v)) = 1;

    end

    function v = time_of_day_pct(states)

		%WARNING: this is correct as written. If statements are reduced into a single line you get a crazy error.
         seconds_in_day         = 86399;
         posix_time             = states.time;
         time_of_day_in_seconds = seconds(timeofday(datetime(posix_time,'ConvertFrom','posixtime')));
         time_of_day_as_percent = time_of_day_in_seconds/seconds_in_day;

         v = time_of_day_as_percent;
    end

    function v = day_of_week(states)

         posix_time = states.time; %WARNING: this is correct as two lines, otherwise you get a crazy error
         day_of_week   = day(datetime(posix_time,'ConvertFrom','posixtime'), 'dayofweek');

         v = day_of_week;
    end

end