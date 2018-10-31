function results = kpirl(episodes, params, verbosity)

    a_start = tic;

    s_a           = s_act_4_2();
    v_b           = @v_basii_4_9;
    r_basii       = @r_basii_4_10;
    adp_algorithm = @approx_policy_iteration_13k;

    N = 50; %30
    M = 90; %90
    S = 04; %03
    W = 04; %04
    
    T = 10;

    p_time = 0;
    s_time = 0;

    episode_count  = numel(episodes);
    episode_length = size(episodes{1},2);

    episode_states = horzcat(episodes{:});
    episode_starts = episode_states(1:episode_length:episode_count*episode_length);

    %this represents the number of times we evaluate an episode start
    %when calculating feature expectation. Through experimentation it
    %seemed important that this wasn't less than 1 (aka, randomly pick 
    %a subset of episode starts) while anything greater than 1 didn't add
    %much accuracy but greatly increased execution time.
    EVAL_N = 2;

    [r_i, r_p, r_b] = r_basii();

    r_n = size(r_p,2);
    r_e = @(states) double((1:r_n)' == r_i(states));

    s_1 = @() episode_starts{randi(numel(episode_starts))};    

    fprintf(1,'Start of Algorithm4 \n');

    params = setDefaults(params);

    if params.seed ~= 0
        rng(params.seed);
    end

    E = 0;
    C = 0;

    for i = 1:numel(episodes)
        for t = 1:size(episodes{i},2)
            assert(all(r_p * r_e(episodes{i}{t}) == r_b(episodes{i}{t})), 'something is wrong with the reward basii');
            C = C + (r_i(episodes{i}{t}) ~= 1);
            E = E + params.gamma^(t-1) * r_e(episodes{i}{t});
        end
    end

    E = E./numel(episodes);
    C = C./numel(episodes);
    
    fprintf('Features Expectations Finished. There were an average of %.3f touches per episode. \n',C);

    ff = k(r_p,r_p,params.kernel);

    i  = 1;
    rs = {};
    ss = {};
    sb = {};
    ts = {};

    % Generate arbitray reward

    rs{i} = rand(1,size(ff,1))*ff;
    s_r   = @(s) rs{i}(r_i(s));

    t_start = tic;
        Pf = adp_algorithm(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W, true);
    np_time = toc(t_start);

    t_start = tic;
        ss{i} = policy_eval_at_states(Pf{N+1}, episode_starts, r_e, params.gamma, T, @huge_trans_pre, EVAL_N);
    ns_time = toc(t_start);

    p_time = p_time + np_time;
    s_time = s_time + ns_time;
    
    sb{i} = ss{i};
    ts{i} = Inf;

    if verbosity ~= 0
        fprintf('Completed IRL iteration, i=%03d, t=%8.6f, p_time=%06.3f, s_time=%06.3f\n',[i,ts{i}, np_time, ns_time]);
    end

    i = 2;

    while 1

        rs{i} = (E-sb{i-1})'*ff;
        s_r   = @(s) rs{i}(r_i(s));

        t_start = tic;
            Pf = adp_algorithm(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W, true);
        np_time = toc(t_start);

        t_start = tic;
            ss{i} = policy_eval_at_states(Pf{N+1}, episode_starts, r_e, params.gamma, T, @huge_trans_pre, EVAL_N);
        ns_time = toc(t_start);

        ts{i} = sqrt(E'*ff*E + sb{i-1}'*ff*sb{i-1} - 2*E'*ff*sb{i-1});

        p_time = p_time + np_time;
        s_time = s_time + ns_time;

        if verbosity ~= 0
            fprintf('Completed IRL iteration, i=%03d, t=%8.6f, p_time=%06.3f, s_time=%06.3f\n',[i,ts{i}, np_time, ns_time]);
        end

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
            break;
        end

        i = i + 1;

        sn       = (ss{i-1}-sb{i-2})'*ff*(E-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*ff*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
    end

    [m,m_i] = min(diag((E-cell2mat(ss))'*ff*(E-cell2mat(ss))));

    a_time = toc(a_start);
    
    if verbosity ~= 0
        fprintf('\n');
        fprintf(1,'FINISHED IRL,i=%d, t=%f \n',i,ts{i});
        fprintf(1,'p_time=%.2f; s_time=%.2f; a_time=%.2f \n',[p_time, s_time, a_time]);
    end    
    
    results = struct(...        
          'rewards'          , rs{i}     ...
        , 'feature_distance' , m         ...
        , 'expert_touches'   , C         ...
        , 'expert_visits'    , E         ...
        , 'learned_visits'   , ss{i}     ... 
        , 'expert_features'  , r_p*E     ...
        , 'learned_features' , r_p*ss{i} ...
        , 'sb'               , sb{i-1}   ...
        , 'a_time'           , a_time    ...
        , 'm_index'          , m_i       ...
        , 'iterations'       , i         ...
    );
    
end

function p = setDefaults(params)
    % Fill in default parameters.
    if ~isfield(params,'seed')
        params.('seed') = 0;
    end

    if ~isfield(params,'kernel')
        params.('kernel') = 1;
    end

    if ~isfield(params,'sigma')
        params.('sigma') = 1;
    end

    if ~isfield(params,'gamma')
        params.('gamma') = .9;
    end

    if ~isfield(params,'epsilon')
        params.('epsilon') = .01;
    end
    
    if ~isfield(params,'kernel')
        params.('kernel') = 1;
    end

    p = params;
end

function k = k(x1, x2, kernel)
    p = 2;
    c = 1;
    s = .6;

    switch kernel
        case 1
            b = k_dot();
        case 2
            b = k_polynomial(k_hamming(1),p,c);
        case 3
            b = k_hamming(0);
        case 4
            b = k_equal(k_norm());
        case 5
            b = k_gaussian(k_norm(),s);
        case 6
            b = k_exponential(k_norm(),s);
        case 7
            b = k_anova(size(x1,1));
        case 8
            b = k_exponential_compact(k_norm(),s);
    end

    k = b(x1,x2);
end