function trajectories = rem_trajectories()
    trajectories = read_trajectory_episodes_from_file([fullfile(fileparts(which(mfilename))) '/../../data/'], 'matlab-trajectories.csv');
end

function te = read_trajectory_episodes_from_file(path, file)

    paramaters = rem_paramaters();

    trajectory_observations = csvread([path, file]);
    trajectory_states       = states_from(trajectory_observations, paramaters.max_hist);

    trajectory_episodes_length    = paramaters.epi_size;
    trajectory_episodes_step_size = paramaters.epi_step;

    trajectory_epsiodes_start  = 4;
    trajectory_epsiodes_finish = numel(trajectory_states) - trajectory_episodes_length;
    trajectory_episodes_count  = floor((trajectory_epsiodes_finish - trajectory_epsiodes_start)/trajectory_episodes_step_size);

    te = cell(1,trajectory_episodes_count);

    for e = 1:trajectory_episodes_count
       episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_step_size);
       episode_stop  = episode_start + trajectory_episodes_length - 1;

       te{e} = trajectory_states(episode_start:episode_stop); 
    end
end

function s = states_from(observations, max_hist)

    s = cell(1,size(observations,1));

    for i = 1:size(observations,1)
        o = observations(i,:);

        s{i} = o(1,o(1,:)~=0)';

        if(size(s{i},1) > max_hist*2)
            s{i} = s{i}(end-(max_hist)*2+1:end,1);
        end
    end

end