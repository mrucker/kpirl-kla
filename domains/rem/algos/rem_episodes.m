function e = rem_episodes()

    expert_episodes = rem_expert_episodes();
    
    function e = to_e(reward)
        if(nargin == 0)
            e = expert_episodes;
        end
    
        if(nargin == 1)
            e = rem_reward_episodes(reward);
        end
    end

    e = @to_e;
end

function episodes = rem_reward_episodes(reward)

    domain = 'rem';

    [t_s       ] = feval([domain '_transitions']);
    [parameters] = feval([domain '_parameters']);

    epi_count  = parameters.samples;
	epi_length = parameters.steps;

    policy   = kla_spd(domain, reward);
    episodes = policy2episodes(policy, t_s, epi_count, epi_length);
end

function episodes = rem_expert_episodes()
    episodes = read_episodes_from_file(fullfile(fileparts(which(mfilename)), '..', 'data'), 'matlab-episodes.csv');
end

function e = read_episodes_from_file(path, file)

    parameters = rem_parameters();

    trajectory_observations = csvread([path filesep file]);
    trajectory_states       = states_from(trajectory_observations, parameters.max_hist);

    trajectory_episodes_length    = parameters.epi_size;
    trajectory_episodes_step_size = parameters.epi_step;

    trajectory_epsiodes_start  = 4;
    trajectory_epsiodes_finish = numel(trajectory_states) - trajectory_episodes_length;
    trajectory_episodes_count  = floor((trajectory_epsiodes_finish - trajectory_epsiodes_start)/trajectory_episodes_step_size);

    e = cell(1,trajectory_episodes_count);

    for t = 1:trajectory_episodes_count
       episode_start = trajectory_epsiodes_start + (t-1)*(trajectory_episodes_step_size);
       episode_stop  = episode_start + trajectory_episodes_length - 1;

       e{t} = trajectory_states(episode_start:episode_stop); 
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