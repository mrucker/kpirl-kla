function trajectories = huge_trajectories()
    trajectories = read_trajectory_episodes_from_file([cd '\domains\huge\data\'], 'huge_observed_trajectories.json');
end

function te = read_trajectory_episodes_from_file(path, file)

    trajectory_observations = jsondecode(fileread([path, file]));
    trajectory_states       = huge_states_from(trajectory_observations);

    trajectory_state_trim_count   = 30; %we trim 30 from beginning and end because of noise
    trajectory_episodes_length    = 10; %this is approximately how much time it takes between each touch
    trajectory_episodes_step_size = 1;  %we only do steps of 1 in order to make sure we don't miss important features

    trajectory_epsiodes_start  = trajectory_state_trim_count;
    trajectory_epsiodes_finish = numel(trajectory_states) - trajectory_state_trim_count - trajectory_episodes_length;
    trajectory_episodes_count  = floor((trajectory_epsiodes_finish - trajectory_epsiodes_start)/trajectory_episodes_step_size);

    te = cell(1,trajectory_episodes_count);

    for e = 1:trajectory_episodes_count
       episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_step_size);
       episode_stop  = episode_start + trajectory_episodes_length - 1;

       te{e} = trajectory_states(episode_start:episode_stop); 
    end
end

function s = huge_states_from(observations)

    td = huge_transitions();

    %assumed observation = [x, y, w, h, r, \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && iscolumn(o), observations)), 'each observation must be a numeric col vector');
    assert(all(cellfun(@(o) mod(numel(o)-5, 3) == 0    , observations)), 'each observation must have 5 global features and 3x target features');

    %states = [x, y, dx, dy, ddx, ddy, dddx, dddy, width, height, radius, targets{x,y,age}]
    states    = cell(1,numel(observations)+1);
    states{1} = zeros(11,1);

    %calculates all my cursor basis, now I need to calculate touch basis
    for i = 1:numel(observations)
        o = observations{i};
        s = states{i};

        x  = [s(1:8); o(3); o(4); o(5)];
        u  = o(1:2) - s(1:2);
        ts = o(6:end);

        %states{i+1} = [adp_transition_post_decision(x,u); ts];
        states{i+1} = [td(x,u); ts];
    end

    s = states;
end