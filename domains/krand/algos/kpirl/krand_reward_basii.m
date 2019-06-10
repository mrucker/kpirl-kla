function [v_i, v_p] = krand_reward_basii()
    n_levels = [9, 30, 21, 31, 96, 7];

    state2levels = {
        @rail_type_levels;
        @highway_type_levels;
        @highway_speed_levels;
        @building_type_levels;
        @time_of_day_levels;
        @day_of_week_levels;
    };

    level2features = {
        level2onehot(n_levels(1));
        level2onehot(n_levels(2));
        level2linear(n_levels(3));
        level2onehot(n_levels(4));
        level2linear(n_levels(5));
        level2linear(n_levels(6));
    };

    [v_i, v_p] = basic_basii(n_levels, state2levels, level2features);

    function rail_type_level = rail_type_levels(states)

        rail_type_level = 1+states.rail_type;
        rail_type_level(isnan(rail_type_level)) = 1;

    end

    function highway_type_level = highway_type_levels(states)

        highway_type_level = 1+states.hwy_typ;
        highway_type_level(isnan(highway_type_level)) = 1;

    end

    function highway_speed_level = highway_speed_levels(states)

         highway_speed_level = states.hwy_maxsp;
         highway_speed_level(isnan(highway_speed_level)) = 0;

         highway_speed_level = bin_levels(highway_speed_level, 0, 150, n_levels(3))';
    end

    function building_type_level = building_type_levels(states)

        building_type_level = 1+states.bldg_typ;
        building_type_level(isnan(building_type_level)) = 1;

    end

    function time_of_day_as_level = time_of_day_levels(states)

         seconds_in_day         = 86399;
         posix_time             = states.time; %WARNING: this is correct as two lines, otherwise you get a crazy error
         time_of_day_in_seconds = seconds(timeofday(datetime(posix_time,'ConvertFrom','posixtime')));                  
         time_of_day_as_level   = bin_levels(time_of_day_in_seconds, 0, seconds_in_day, n_levels(5))';
    end

    function day_of_week_level = day_of_week_levels(states)

         posix_time = states.time; %WARNING: this is correct as two lines, otherwise you get a crazy error
         time_day   = day(datetime(posix_time,'ConvertFrom','posixtime'), 'dayofweek');

         day_of_week_level = time_day;
    end

end