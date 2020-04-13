function s2f = krand_features(func)
    params = krand_parameters();

    if(strcmp(func, 'reward'))
        s2f = @states2features;
    end

    if(strcmp(func, 'value'))
        if(params.v_feats == 0)
            s2f = @(states) 1;
        else
            s2f = @states2features;
        end 
    end
end

function f = states2features(states)
    f = cell2mat(arrayfun(@(s) {state2features(s)}, states));
end

function f = state2features(state)
    f = [
        rail_type(state);
        highway_type(state);
        highway_maxspeed(state);
        building_type(state);
        time_of_day_pct(state);
        day_of_week(state);
    ];
end

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

    %WARNING: this is correct as written. If the below statements are reduced into a single line you get a crazy error.
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