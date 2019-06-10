clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

kernel = k_gaussian(k_norm(), .6);
%kernel = k_dot();

krand_parameters(struct('v_basii', '1a', 'N', 20, 'M', 20, 'T', 100, 'W', 10, 'steps',10, 'samples',50, 'gamma',.9, 'epsilon',.001, 'kernel',kernel));

[reward, ~, state_importance] = kpirl('krand');

[r_i, r_p] = krand_reward_basii();

policy = kla('krand', @(s) reward(r_i(s)));

[s_1          ] = krand_random();
[  ~,   ~, t_b] = krand_transitions();

trajectory_count  = 3;
trajectory_length = 10000;

states = zeros(trajectory_count*trajectory_length, 5);

for i = 1:trajectory_count
    state = s_1();
    
    states((i-1)*trajectory_length+1, :) = [state.row, state.col, state.time, i, 1];
    
    for j = 2:trajectory_length
        action = policy(state);
        state  = t_b(state,action);
        
        states((i-1)*trajectory_length+j, :) = [state.row, state.col, state.time, i, j];
    end
end

header = {'row', 'col', 'time', 'trajectory', 'step'};
states = [header; num2cell(states)];
writecell(states, 'trajectory.csv');