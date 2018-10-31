try run '../../../paths'; catch; end

N = 50;%30
M = 90;%90
S = 4; %03
W = 4;

T = 10;
g = .9;

trans_pre = @huge_trans_pre;
trans_pst = @huge_trans_post;

[r_i, r_p, r_b] = r_basii_4_10();

r_n = size(r_p,2);
r_e = @(states) double((1:r_n)' == r_i(states));

v_b = @v_basii_4_9;

r_r = rand(1, size(r_p,2));
r_r = 500*r_r/max(r_r);
r_t = rand(size(r_b(state_rand()),1), 1);

s_1 = @() state_rand();
s_a = s_act_4_2();

R = r_t' * r_p;

s_r = @(s) R(r_i(s));

[Pf, ~, ~, ~, ~, ~, f_time, b_time, m_time, a_time] = approx_policy_iteration_13k(s_1, s_a, s_r, v_b, trans_pst, trans_pre, g, N, M, S, W);
[f_time, b_time, m_time, a_time]

trajectory = generate_trajectory_from_state(Pf{N+1}, state_rand(), trans_pre, 450);
episodes   = read_episodes_from_trajectory(trajectory);

params1 = struct ('epsilon',.0001, 'gamma',.9, 'seed',0, 'kernel', 1);
params2 = struct ('epsilon',.0001, 'gamma',.9, 'seed',0, 'kernel', 5);

result_1 = algorithm4run(episodes, params1, 1);
result_2 = algorithm4run(episodes, params2, 1);

tru_reward_for_each_unique_basii_set   = r_t' * r_p;
irl_reward_for_each_unique_basii_set_1 = result_1.rewards';
irl_reward_for_each_unique_basii_set_2 = result_2.rewards';

tru_reward_for_each_unique_basii_set   = tru_reward_for_each_unique_basii_set   - min(tru_reward_for_each_unique_basii_set);
irl_reward_for_each_unique_basii_set_1 = irl_reward_for_each_unique_basii_set_1 - min(irl_reward_for_each_unique_basii_set_1);
irl_reward_for_each_unique_basii_set_2 = irl_reward_for_each_unique_basii_set_2 - min(irl_reward_for_each_unique_basii_set_2);

tru_reward_for_each_unique_basii_set   = tru_reward_for_each_unique_basii_set/max(tru_reward_for_each_unique_basii_set);
irl_reward_for_each_unique_basii_set_1 = irl_reward_for_each_unique_basii_set_1/max(irl_reward_for_each_unique_basii_set_1);
irl_reward_for_each_unique_basii_set_2 = irl_reward_for_each_unique_basii_set_2/max(irl_reward_for_each_unique_basii_set_2);

[norm(tru_reward_for_each_unique_basii_set - irl_reward_for_each_unique_basii_set_1, 1), norm(tru_reward_for_each_unique_basii_set - irl_reward_for_each_unique_basii_set_2, 1);]

function s = state_init()
    s = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156;626;555;155;2249;305;60];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [1588;768;0;0;0;0;0;0;3175;1535;156;626;555;155;2249;305;60];
   };
end

function s = state_rand()
    population = state_init();

    s = population{randi(numel(population))};
end

function E = generate_trajectory_from_state(Pf, state, transition_pre, trajectory_length)

    trajectory    = cell(1,trajectory_length);
    trajectory{1} = state;

    for t = 2:trajectory_length
        trajectory{t} = transition_pre(trajectory{t-1}, Pf(trajectory{t-1}));
    end

    E = trajectory;
    
end

function te = read_episodes_from_trajectory(trajectory)

    trajectory_episodes_count  = 380; %we finish at (380+10+30) to trim the last second in case of noise
    trajectory_episodes_steps  = 1;   %we only do steps of 1 in order to make sure we don't miss important features
    trajectory_epsiodes_start  = 30;  %we start at 30 to trim the first second in case of noise
    trajectory_episodes_length = 10;  %this was arbitrarily chosen, but it seems to subjectively work well 

    te = cell(1,trajectory_episodes_count);

    for e = 1:trajectory_episodes_count
       episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_steps);
       episode_stop  = episode_start + trajectory_episodes_length - 1;

       te{e} = trajectory(episode_start:episode_stop); 
    end
end