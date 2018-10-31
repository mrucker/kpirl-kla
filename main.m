clear; paths; close all

%all these observations are in the trial 1 dataset

%study 1 -- 1ff40e9f5818b8978.json super back and forth (RewardId = 2)

%study 1 -- 1a92ecaf5864960f1.json very few touches but with correct radius so RL can get touches (RewardId = 3)
    %this works well but brings up an interesting conundrum. It scores all the targets highly 
    %but the dead space higher... This is broken by the way I handle the "top 10" since it makes 
    %several states equal to empty space perhaps a solution to this is to subtract empty space 
    %from targets making the majority of targets show 0 value instaed of majority showing .98

%study 1 -- a3cb0e1e586811391.json stayed entirely on the right third of the screen, otherwise normal.

%study 2 -- 1b37aabe5971bcc6c.json a normal test where I attempted to touch as many targets as I could

%study 2 -- 452515135984d0d0d.json the T_N field for this experiment is extremely high in the ThesisExperiments table.

%run_irl_on_one_experiment('c45a', '110e53fe5a585b7b1');
%run_irl_on_all_experiments('c45a');
%run_irl_on_new_experiments('c45a');

run_irl_on_two_experiments('c45a', '1eafe9a45a58678af', '5cbf004e5a58678ae');
%run_irl_on_two_experiments('c45a', '214803d35a5897ace', '1c29e0b85a5897ace');

function run_irl_on_all_experiments(study_id)
    obs_path = ['../../data/studies/', study_id, '/observations/'];

    yn = input(['Are you sure you want to run irl on every experiment in study ', study_id, '? [y,n] ' ], 's');
    
    if(yn == 'n') 
        fprintf('aborting...\n\n');
        return;
    end
    
    fprintf('\n\n');
    
    files = dir([obs_path, '*.json']);
    
    for i = 1:numel(files)
        
        experiment_id = files(i).name(1:end-5);
        
        fprintf(['processing ' experiment_id ' (%.0f/%.0f)... \n\n'], [i,numel(files)]);
        run_irl_on_one_experiment(study_id, experiment_id);
    end
end

function run_irl_on_new_experiments(study_id)
    obs_path = ['../../data/studies/', study_id, '/observations/'];

    yn = input(['Are you sure you want to run irl on every experiment in study ', study_id, '? [y,n] ' ], 's');
    
    if(yn == 'n') 
        fprintf('aborting...\n\n');
        return;
    end
    
    fprintf('\n\n');
    
    files = dir([obs_path, '*.json']);
    
    for i = 1:numel(files)
        
        if exist(['../../data/studies/', study_id, '/results/' files(i).name], 'file') == 2
            
            fprintf([files(i).name(1:end-5) ' (%.0f/%.0f) already existed. Continuing to next file...\n\n'],[i,numel(files)]);
            
            continue;
        end
        
        experiment_id = files(i).name(1:end-5);
        
        fprintf(['processing ' experiment_id ' (%.0f/%.0f)... \n\n'], [i,numel(files)]);
        run_irl_on_one_experiment(study_id, experiment_id);
    end
end

function run_irl_on_one_experiment(study_id, experiment_id)

    obs_path = ['../../data/studies/', study_id, '/observations/'];
    res_path = ['../../data/studies/', study_id, '/results 4_10_1/'];

    trajectory_episodes = read_trajectory_episodes_from_file(obs_path, experiment_id);

    params  = struct ('epsilon',.0001, 'gamma',.9, 'seed',0, 'kernel', 5);
    results = algorithm4run(trajectory_episodes, params, 1);

    results.('episode_count') = numel(trajectory_episodes);
        
    write_results_to_file(results, res_path, experiment_id);
    write_results_to_screen(results, experiment_id);
end

function run_irl_on_two_experiments(study_id, experiment_id_1, experiment_id_2)

    obs_path = ['../../data/studies/', study_id, '/observations/'];
    res_path = ['../../data/studies/', study_id, '/results 4_10_2/'];

    trajectory_episodes_1 = read_trajectory_episodes_from_file(obs_path, experiment_id_1);
    trajectory_episodes_2 = read_trajectory_episodes_from_file(obs_path, experiment_id_2);

    trajectory_episodes = horzcat(trajectory_episodes_1, trajectory_episodes_2);
    
    params  = struct ('epsilon',.000001, 'gamma',.9, 'seed',0, 'kernel', 5);
    results = algorithm4run(trajectory_episodes, params, 1);

    results.('episode_count') = numel(trajectory_episodes);
        
    write_results_to_file(results, res_path, [experiment_id_1, '-', experiment_id_2]);
    write_results_to_screen(results, [experiment_id_1, '-', experiment_id_2]);
end

function write_results_to_file(results, res_path, experiment_id)
    file_id = fopen([res_path, experiment_id, '.json'], 'w');
    fprintf(file_id, '%s', jsonencode(results));
    fclose(file_id);
    
    cleaned_rewards_1 = rewards_clean_1(results.rewards);
    cleaned_rewards_2 = rewards_clean_2(results.rewards);
   
    fig = rewards_figure(experiment_id, cleaned_rewards_1, cleaned_rewards_2);
    
    %this line is necessary. See the link below for an explanation.
    %https://www.mathworks.com/matlabcentral/answers/382806-how-can-i-save-an-invisible-figure-in-matlab-but-make-the-figure-visible-when-reopened
    set(fig, 'CreateFcn', 'set(gcbo,''Visible'',''on'')'); 
    
    savefig(fig,[res_path experiment_id '.fig'])
end

function write_results_to_screen(results, experiment_id)

    fprintf('results for %s', experiment_id)

    results.feature_distance
    [results.expert_features, results.learned_features]'

    cleaned_rewards_1 = rewards_clean_1(results.rewards);
    cleaned_rewards_2 = rewards_clean_2(results.rewards);

    fprintf('%s\n\n', jsonencode(cleaned_rewards_1));
    fprintf('%s\n\n', jsonencode(cleaned_rewards_2));

    figure(rewards_figure(experiment_id, cleaned_rewards_1, cleaned_rewards_2));
end

function te = read_trajectory_episodes_from_file(path, experiment_id)

    trajectory_observations = jsondecode(fileread([path, experiment_id, '.json']));
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

function rc = rewards_clean_1(rewards)
    %result(result > prctile(result,97)) = prctile(result,97);

    epsilon_result = rewards - rewards(1);

    if(max(epsilon_result) == 0)
        epsilon_result(epsilon_result == 0) = 1;
    end

    epsilon_result(epsilon_result<0) = 0;

    min_result = min(epsilon_result);
    max_result = max(epsilon_result);

    rc = round((epsilon_result - min_result)/(max_result-min_result),2);
end

function rc = rewards_clean_2(rewards)

    rewards(rewards > prctile(rewards,97)) = prctile(rewards,97);

    epsilon_result = rewards - rewards(1);

    if(max(epsilon_result) == 0)
        epsilon_result(epsilon_result == 0) = 1;
    end

    epsilon_result(epsilon_result<0) = 0;

    min_result = min(epsilon_result);
    max_result = max(epsilon_result);

    normal_epsilon_result = round((epsilon_result - min_result)/(max_result-min_result),2);

    rc = normal_epsilon_result;
end

function rf = rewards_figure(experiment_id, cleaned_rewards_1, cleaned_rewards_2)
    rf = figure('NumberTitle', 'off', 'Name', ['rewards for ' experiment_id], 'Visible', 'off');   
    
    subplot(2,1,1);
    hist(cleaned_rewards_1);
    title('empty state set to 0')

    subplot(2,1,2);
    hist(cleaned_rewards_2);
    title('top 3% states set to 1')    
end