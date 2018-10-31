clear
close all
try run('../../paths.m'); catch; end

rewd_count = 30;
eval_steps = 10;

trans_pre = @(s,a) huge_trans_pre (s,a);
trans_pst = @(s,a) huge_trans_post(s,a);

[r_i, r_p, r_b] = huge_basii_r();

s_1 = @() state_rand();
s_a = s_act_4_2();
v_b = @v_basii_4_4;

%algorithm_2   == (lin ols regression with n-step Monte Carlo                             )
%algorithm_5   == (gau ridge regression                                                   )
%algorithm_8   == (gau svm regression with n-step Monte Carlo, BAKF, and ONPOLICY sampling)
%algorithm_8b  == (algorithm_8 except I've reintroduced an old bug that made it run better)
%algorithm_12  == (algorithm_8 but with bootstrapping after n-step Monte Carlo            )
%algorithm_13  == (algorithm_8 but with interval estimation to choose the first action    )
%algorithm_13b == (algorithm_13 but with a small bug fix around the on-policy distribution)
%algorithm_13c == (algorithm_13b but with a small bug fix in the confidence interval      )
%algorithm_13d == (algorithm_13b but with a small change to cache values in iterations    )
%algorithm_13e == (algorithm_13b but with a change to calculate all values once each N    )
%algorithm_13f == (algorithm_13e but adding in policy_iter data to the kernel value basii )
%algorithm_13g == (algorithm_13f but more intelligent explore/exploit logic               )
%algorithm_13h == (algorithm_13g but more intelligent explore/exploit logic and faster Vf )
%algorithm_13i == (algorithm_13h but with new level-based value architecture for speed    )
%algorithm_14  == (true TD(lambda) with bootstrap, confidence interval and on-policy dist )

algo_a = @(s_r) approx_policy_iteration_2  (s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 2, 3);  %  no-opt

algo_j = @(s_r) approx_policy_iteration_13b(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt

algo_l = @(s_r) approx_policy_iteration_13e(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt
algo_m = @(s_r) approx_policy_iteration_13e(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 10, 50, 7, 3); %  no-opt

algo_n = @(s_r) approx_policy_iteration_13f(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt
algo_o = @(s_r) approx_policy_iteration_13f(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 5, 400, 5, 4); %  no-opt

algo_p = @(s_r) approx_policy_iteration_13g(s_1, s_a, s_r, v_b, trans_pst, trans_pre, 0.9*1.0, 30, 50, 5, 3); %  no-opt

algo_q = @(s_r) approx_policy_iteration_13h(s_1, s_a, s_r, @v_basii_4_4, trans_pst, trans_pre, 0.9*1.0, 30, 90, 3, 4); %  no-opt

algo_r = @(s_r) approx_policy_iteration_13i (s_1, s_a, s_r, @v_basii_4_9, trans_pst, trans_pre, 0.9*1.0, 30, 90, 3, 4); %  no-opt

algo_s = @(s_r) approx_policy_iteration_13k (s_1, s_a, s_r, @v_basii_4_9    , trans_pst, trans_pre, 0.9*1.0, 30 , 90,  4, 4); %  no-opt
algo_t = @(s_r) approx_policy_iteration_lspi(s_1, s_a, s_r, 'huge_basis_3_1', trans_pst, trans_pre, 0.9*1.0, 30, 200, 10, 0); %  no-opt
algo_u = @(s_r) approx_policy_iteration_lspi(s_1, s_a, s_r, 'huge_basis_3_2', trans_pst, trans_pre, 0.9*1.0, 30, 200, 10, 0); %  no-opt
%algo_v = @(s_r) approx_policy_iteration_kspi(s_1, s_a, s_r, 'huge_basis_5'  , trans_pst, trans_pre, 0.9*1.0, 30,  75, 10, 0); %  no-opt

algo_v = @(s_r) kla (s_1, s_a, s_r, @v_basii_4_9    , trans_pst, trans_pre, 0.9*1.0, 30 , 90,  4, 4); %  no-opt
%algo_w = @(s_r) approx_policy_iteration_13k (s_1, s_a, s_r, @v_basii_4_9    , trans_pst, trans_pre, 0.9*1.0, 70 , 90,  4, 4); %  no-opt
%algo_x = @(s_r) approx_policy_iteration_13k (s_1, s_a, s_r, @v_basii_4_9    , trans_pst, trans_pre, 0.9*1.0, 100, 90,  4, 4); %  no-opt

algos = {
%   algo_a, 'algorithm_2  (G=0.9, L=1.0, N=30, M=50 , S=2, W=3)';
%   algo_j, 'algorithm_13b(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
%   algo_l, 'algorithm_13e(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
%   algo_m, 'algorithm_13e(G=0.9, L=1.0, N=10, M=50 , S=7, W=3)';
%   algo_n, 'algorithm_13f(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';
%   algo_o, 'algorithm_13f(G=0.9, L=1.0, N=10, M=200, S=7, W=3)';
%   algo_p, 'algorithm_13g(G=0.9, L=1.0, N=30, M=50 , S=5, W=3)';

   %algo_q, 'algorithm_13h(G=0.9, L=1.0, N=30, M=90 , S=3, W=4)';
   %algo_r, 'algorithm_13i(G=0.9, L=1.0, N=30, M=90 , S=3, W=4)';
   %algo_s, 'algorithm_13ks';
   algo_t, 'algorithm_lsp1';
   algo_u, 'algorithm_lsp2';
   algo_v, 'algorithm_ksp1';
   %algo_v, 'algorithm_13kv';
   %algo_w, 'algorithm_13kw';
   %algo_x, 'algorithm_13kx';
   
};

states_c = cell(1, rewd_count);
reward_f = cell(1, rewd_count);

for i = 1:rewd_count
    R = reward_theta(size(r_p,1))' * r_p;
    reward_f{i} = @(s) R(r_i(s));
    states_c{i} = state_init();
end

i = 137;


while true
    i        = i + 1;
    R        = reward_theta(size(r_p,1))' * r_p;
    reward_f = @(s) R(r_i(s));
    states_c = state_init();

    %R_control = [zeros(size(r_p,1)-1,1);-1/4]* r_p + 1;
    
    for a_i = 1:size(algos,1)
        [Pf, ~, ~, ~, ~, ~, fT, bT, Tf, aT] = algos{a_i,1}(reward_f);
        
        %Pe = policy_eval_at_states(Pf{end}, states_c, @(s) r_p(:,r_i(s)), 0.9, eval_steps, trans_pre, 200);
        %Pe'

        Vf = num2cell([0,arrayfun(@(p_i) policy_eval_at_states(Pf{p_i}, states_c, reward_f, 0.9, eval_steps, trans_pre, 50), 2:numel(Pf))]);
        file_id = fopen('performance.csv', 'at');
        p_results_3(file_id, algos{a_i,2}, i, Vf, Tf);
        fclose(file_id);
    end
    
end

for a_i = 1:size(algos,1)

    fT = zeros(1,rewd_count);
    bT = zeros(1,rewd_count);
    vT = zeros(1,rewd_count);
    aT = zeros(1,rewd_count);

    Pf = cell(rewd_count, 1);
    Tf = cell(rewd_count, 1);
    
    for r_i = 1:rewd_count
        [Pf{r_i}, ~, ~, ~, ~, ~, fT(r_i), bT(r_i), Tf{r_i}, aT(r_i)] = algos{a_i,1}(reward_f{r_i});
    end
    
    %Pv = arrayfun(@(r_i) policy_eval_at_states(Pf{r_i}{end}, states_c{r_i}, reward_f{r_i}, 0.9, eval_steps, trans_pre, 100), 1:rewd_count);
    %p_results_1(algos{a_i,2}, fT, bT, vT, aT, Pv);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Vf = arrayfun(@(r_i) num2cell([0,arrayfun(@(p_i) policy_eval_at_states(Pf{r_i}{p_i}, states_c{r_i}, reward_f{r_i}, 0.9, eval_steps, trans_pre, 200), 2:numel(Pf{r_i}))]), 1:numel(Pf), 'UniformOutput', false);
    p_results_2(algos{a_i,2}, Vf, Tf);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Vs = zeros(1,numel(Pf)-1);
    
    %for Pf_i = 2:numel(Pf)
    %    Vs(Pf_i-1) = policy_eval_at_states(Pf{Pf_i}, eval_states, eval_reward, 0.9, eval_steps, trans_pre, 50);
    %end

    %d_results_3(algos{a_i,2}, Vs);
end

fprintf('\n');

function s = state_init()
    s = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156;626;555;155;2249;305;60];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [1588;768;0;0;0;0;0;0;3175;1535;156;626;555;155;2249;305;60];
       [980;316;-17;4;82;5;65;6;1910;929;94.5;873;286;428;1430;270;412;1009;698;252;721;409;35;838;432;29];
       [827;479;-5;12;-5;12;-5;12;2259;1238;118.5;854;453;972;664;940;904;1608;857;604];
       [393;392;-49;-67;10;15;39;41;1910;929;94.5;498;613;681;288;394;423;351;328;316;401;512;20];
       [704;532;-111;100;-124;72;-46;-12;1270;684;66;725;479;535;1002;219;385;1117;534;55];
       [1350;478;0;0;0;0;0;0;1356;662;67.5;564;371;489;310;330;304;1062;321;67;896;256;44];
       [845;191;4;-10;2;-5;1;-7;1907;975;96;560;626;583;339;587;390;1584;784;150;221;809;105];
       [503;265;503;265;503;265;503;265;1014;652;57];
       [411;256;0;0;0;0;1;0;1350;631;66;1014;116;896;347;124;892;924;176;815;264;282;707;1048;190;622;422;238;607;537;284;433;352;189;32];
       [713;479;-1;0;5;-1;-86;-14;1350;631;66;786;476;901;1282;464;872;1166;145;102;1262;422;29];
       [1188;178;-13;0;-7;-3;-7;-5;1350;631;66;374;331;977;911;558;289;612;301;36;0;0;15];
       [221;346;-74;0;-22;-2;28;-5;1356;652;66;912;129;556;515;120;145;770;128;119;0;0;7];
       [543;335;0;1;2;1;-69;2;1356;652;66;608;378;744;875;260;446;166;82;265;314;279;31];
       [694;274;-5;1;2;-1;-6;8;1356;652;66;427;456;786;680;290;682;319;105;641;491;357;311];
       [778;755;0;0;0;0;0;0;1430;784;75;938;501;797;445;295;534;938;249;320;731;229;207;755;621;99;0;0;6];
       [849;348;-14;2;-14;2;-14;2;1430;784;75;1304;227;905;654;556;475;321;550;471;422;422;237];
       [552;485;0;0;0;0;-3;1;1430;784;75;540;468;779;384;279;561;947;329;545;1091;609;329;882;305;241;1214;245;200];
       [263;80;-41;5;-30;5;-19;5;1270;573;60;174;127;728;376;264;685;956;183;548;440;98;394;166;215;341;1046;444;202;758;276;144;670;350;83];
   };
end

function s = state_rand()
    population = state_init();

    s = population{randi(numel(population))};
end

function rt = reward_theta(basii_count)
    %rt = [zeros(basii_count-1,1);-1/4];
    %rt = [zeros(basii_count-1,1);1];
    rt = 2*rand(basii_count,1) - 1;
    %rt = [-.25*rand(basii_count-1,1);100];
end

function p_results_1(test_algo_name, f_time, b_time, m_time, a_time, P_val)    
    fprintf('%s '             , test_algo_name);
    fprintf('f_time = %5.2f; ', mean(f_time));
    fprintf('b_time = %5.2f; ', mean(b_time));
    fprintf('m_time = %5.2f; ', mean(m_time));
    fprintf('a_time = %5.2f; ', mean(a_time));
    fprintf('VAL = %7.3f; '   , mean(P_val));
    fprintf('\n');
end

function p_results_2(~, test_algo_name, Vf, Tf)
    for r_i=1:numel(Tf)
        for p_i=1:numel(Tf{1})
            fprintf('%s\t%.0f\t%.0f\t%f\t%f\n', test_algo_name, r_i, p_i, Vf{r_i}{p_i}, Tf{r_i}{p_i});
        end
    end
end

function p_results_3(fid, test_algo_name, r_i, Vf, Tf)
    for p_i=1:numel(Tf)
        fprintf(1, '%s,%.0f,%.0f,%f,%f\n', test_algo_name, r_i, p_i, Vf{p_i}, Tf{p_i});
        if(fid~= 1)
            fprintf(fid, '%s,%.0f,%.0f,%f,%f\n', test_algo_name, r_i, p_i, Vf{p_i}, Tf{p_i});
        end
    end
end


function d_results_1(test_algo_name, Ks, As)

    flat_ns = cell2mat(arrayfun(@(ni) ni*ones(size(Ks{ni})), 1:numel(Ks), 'UniformOutput', false));
    flat_ks = cell2mat(Ks);
    flat_as = cell2mat(As);
    
    [k_val,~,gk] = unique(flat_ks);
    [n_val,~,gn] = unique(flat_ns);

    %max(K), average(K), var(K), number of (K) each Ks{i}
    nk_avg = grpstats(flat_ks, gn, @mean);
    nk_max = grpstats(flat_ks, gn, @max);
    nk_var = grpstats(flat_ks, gn, @var);
    nk_num = grpstats(flat_ks, gn, @numel);

    %max(A), average(A), var(A), min(A) per unique value of N over all Ns, As
    na_min = grpstats(flat_as, gn, @min);
    na_avg = grpstats(flat_as, gn, @mean);
    na_max = grpstats(flat_as, gn, @max);
    na_var = grpstats(flat_as, gn, @var);

    %max(A), min(A), average(A), Var(A) per unique value of K over all Ks, As
    ka_min = grpstats(flat_as, gk, @min);
    ka_avg = grpstats(flat_as, gk, @mean);
    ka_max = grpstats(flat_as, gk, @max);
    ka_var = grpstats(flat_as, gk, @var);

    figure('NumberTitle', 'off', 'Name', test_algo_name);

    subplot(3,1,1);
    plot(n_val, nk_num, n_val, nk_avg, n_val, nk_max, n_val, nk_var);
    title('visits by iteration')
    xlabel('iteration index')
    legend('k num', 'k avg', 'k max', 'k var')

    subplot(3,1,2);
    plot(n_val, na_min, n_val, na_avg, n_val, na_max, n_val, na_var);
    title('alpha by iteration')
    xlabel('iteration index')
    legend('a min', 'a avg', 'a max', 'a var')

    subplot(3,1,3);
    hold on
    plot(k_val, ka_min, k_val, ka_avg, k_val, ka_max, k_val, ka_var);
    title('alpha by visits')
    xlabel('vb visitation count')
    legend('a min', 'a avg', 'a max', 'a var')
end

function d_results_2(test_algo_name, Ss, Ws, Vs)

    figure('NumberTitle', 'off', 'Name', test_algo_name);

    scatter3(Ss, Ws, Vs, '.', 'b');
    xlabel('S')
    ylabel('W')
    zlabel('V')
end

function d_results_3(test_algo_name, Vs)

    figure('NumberTitle', 'off', 'Name', test_algo_name);

    scatter(1:numel(Vs), Vs, '.');
    title('Convergence of value function');
    xlabel('N')
    ylabel('V')
end