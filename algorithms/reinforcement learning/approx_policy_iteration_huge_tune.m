clear
close all
try run('../../paths.m'); catch; end

rewd_count = 3;
eval_steps = 10;

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

act_methd = @s_act_4_2;
rew_basii = @r_basii_4_9;
val_basii = @v_basii_4_9;

[r_i, r_p, r_b] = rew_basii();

v_b = val_basii;
s_1 = @state_rand;
s_a = act_methd();

algos = {
    @approx_policy_iteration_13k, 'algorithm_13k';
};

states_c = cell(1, rewd_count);
reward_f = cell(1, rewd_count);

for i = 1:rewd_count
    R = reward_theta(size(r_p,1))' * r_p;
    reward_f{i} = @(s) R(r_i(s));
    states_c{i} = state_init();
end

for a_i = 1:size(algos,1)

    for tuning = tunings()

        fT = zeros(1,rewd_count);
        bT = zeros(1,rewd_count);
        mT = zeros(1,rewd_count);
        aT = zeros(1,rewd_count);

        max_vs = zeros(1,rewd_count);
        avg_vs = zeros(1,rewd_count);
        lst_vs = zeros(1,rewd_count);
        var_vs = zeros(1,rewd_count);

        for r_i = 1:rewd_count

            G = 0.9;
            L = tuning(1);
            N = tuning(2);
            M = tuning(3);
            S = tuning(4);
            W = tuning(5);

            algo_s = @(s_r) approx_policy_iteration_13i(s_1, s_a, s_r, @v_basii_4_9, trans_pst, trans_pre, 0.9*1.0, 30, 90, 3, 4); %  no-opt

            [Pf, ~, ~, ~, ~, ~, fT(r_i), bT(r_i), mT(r_i), aT(r_i)] = algos{a_i,1}(s_1, s_a, reward_f{r_i}, v_b, trans_pst, trans_pre, G*L, N, M, S, W, false);

            eval_states = states_c{r_i};
            eval_reward = reward_f{r_i};

            vs = zeros(1, numel(Pf)-1);

            parfor Pf_i = 2:numel(Pf)
                vs(Pf_i-1) = policy_eval_at_states(Pf{Pf_i}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 50);
            end

            max_vs(r_i) = max(vs);
            avg_vs(r_i) = mean(vs(6:end));
            lst_vs(r_i) = vs(end);
            var_vs(r_i) = var(vs(6:end));
        end

        p_results(algos{a_i,2}, tuning, max_vs, avg_vs, lst_vs, var_vs, fT, bT, mT, aT);
    end

end

fprintf('\n');

function t = tunings()
    L = 1;
    N = 30:10:50;
    M = 10:20:90;
    S = 3:1:9;
    W = 2:4;

    [cw, cs, cm, cn, cl] = ndgrid(W, S, M, N, L);

    t = [cl(:), cn(:), cm(:), cs(:), cw(:)]';
end

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

function t = reward_theta(basii_count)
    %t = [zeros(basii_count-1,1);1];
    t = 2*rand(basii_count,1) - 1;
    %t = [-.25*rand(basii_count-1,1);100];
end

function p_results(algo_name, tuning, max_vs, avg_vs, lst_vs, var_vs, f_time, b_time, m_time, a_time)
    fprintf('%s', algo_name);
    fprintf('(G=0.9, L=%03.1f, N=%3i, M=%3i, S=%2i, W=%2i) ',tuning);

    fprintf('AVG_MAX_V = %6.3f; '  , mean(max_vs));
    fprintf('AVG_AVG_V = %6.3f; '  , mean(avg_vs));
    fprintf('AVG_LST_V = %6.3f; '  , mean(lst_vs));
    fprintf('AVG_VAR_V = %6.3f; ' , mean(var_vs));

    fprintf('fT = %5.2f; '        , mean(f_time));
    fprintf('bT = %5.2f; '        , mean(b_time));
    fprintf('mT = %5.2f; '        , mean(m_time));
    fprintf('aT = %5.2f; '        , mean(a_time));
    fprintf('\n');
end


