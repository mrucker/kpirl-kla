function trajectories = krand_expert_trajectories()
    trajectories = read_trajectory_episodes_from_file(fullfile(fileparts(which(mfilename)), '..', '..', 'data'), 'krand_test_trajectory.csv');
end

function te = read_trajectory_episodes_from_file(path, file)

    parameters = krand_parameters();

    gw_sz      = parameters.grid_world_size;
    grid_world = parameters.grid_world;

    trajectory_observations = readtable([path filesep file]);
    %trajectory_observations = trajectory_observations(:,[4, 3, 9, 18, 23, 21, 30]);%Long, lat, datetime, rail type, street type, street maxspeed, building type
    trajectory_observations = trajectory_observations(:,[1,2,11]); %Row, column, time (numeric)

    r2_y = table2array(trajectory_observations(:,1)); %sub2ind says it's row, column, but we need to do column, row, because index is transposed between R and matlab
    c2_x = table2array(trajectory_observations(:,2));

    ind = sub2ind([gw_sz gw_sz], c2_x, r2_y);

    trajectory_states = table2struct(grid_world(ind,:));
    R = num2cell(r2_y);
    C = num2cell(c2_x);
    [trajectory_states(:).row] = R{:};
    [trajectory_states(:).col] = C{:};
    
    

    for i = 1:size(trajectory_states,1)
        trajectory_states(i).time = trajectory_observations{i,3}; 
    end

    trajectory_episodes_length    = 400;
    trajectory_episodes_step_size = 50;

    trajectory_epsiodes_start  = 1;
    trajectory_epsiodes_finish = numel(trajectory_states)- trajectory_episodes_length; 
    trajectory_episodes_count  = floor((trajectory_epsiodes_finish - trajectory_epsiodes_start)/trajectory_episodes_step_size);

    te = cell(1,trajectory_episodes_count);

    for e = 1:trajectory_episodes_count
       episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_step_size);
       episode_stop  = episode_start + trajectory_episodes_length - 1;

       te{e} = trajectory_states(episode_start:episode_stop)'; 
    end
end

