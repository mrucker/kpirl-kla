function r2e = huge_episodes()
    expert_episodes = huge_expert_episodes();
    
    function e = to_e(reward)
        if(nargin == 0)
            e = expert_episodes;
        end
    
        if(nargin == 1)
            e = huge_reward_episodes(reward);
        end
    end

    r2e = @to_e;
end

function episodes = huge_reward_episodes(reward)

    domain = 'huge';

    [t_s   ] = feval([domain '_transitions']);
    [params] = feval([domain '_parameters']);

    epi_count  = params.samples;
    epi_length = params.steps;

    policy   = kla_spd(domain, reward);
    
    episodes = policy2episodes(policy, t_s, epi_count, epi_length);
end

function e = huge_expert_episodes()
    e = episodes_from_file(fullfile(fileparts(which(mfilename)), '..', 'data'), 'huge_observed_episodes.json');
end

function e = episodes_from_file(path, file)

    observations = jsondecode(fileread([path filesep file]));
    states       = states_from_observation(observations);

    episodes_length  = 10;                 %this is approximately how much time it takes between each touch
    episodes_start   = 30;                 %we trim 30 from beginning and end because of noise
    episodes_stop    = numel(states) - 30; %we trim 30 from beginning and end because of noise
    episodes_spacing = 1;                  %we only do steps of 1 in order to make sure we don't miss important features
    
    episodes_count  = floor((episodes_stop - episodes_start - episodes_length)/episodes_spacing);

    e = cell(1,episodes_count);

    for t = 1:episodes_count
       episode_start = episodes_start + (t-1)*(episodes_spacing);
       episode_stop  = episode_start + episodes_length - 1;

       e{t} = states(episode_start:episode_stop); 
    end
end

function s = states_from_observation(observations)

    td = huge_transitions();

    %assumed observation = [x, y, w, h, r, \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && iscolumn(o), observations)), 'each observation must be a numeric col vector');
    assert(all(cellfun(@(o) mod(numel(o)-5, 3) == 0    , observations)), 'each observation must have 5 global features and 3x target features');

    %states = [x, y, dx, dy, ddx, ddy, dddx, dddy, width, height, radius, targets{x,y,age}]
    states    = cell(1,numel(observations)+1);
    states{1} = zeros(11,1);

    for i = 1:numel(observations)
        o = observations{i};
        s = states{i};

        x  = [s(1:8); o(3); o(4); o(5)];
        u  = o(1:2) - s(1:2);
        ts = o(6:end);

        states{i+1} = [td(x,u); ts];
    end

    s = states;
end