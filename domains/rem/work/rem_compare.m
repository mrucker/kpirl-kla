clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

%WARNING: The distribution of V is unknown making traditional confidence bounds around mean using SE more suspect
%WARNING: reducing eval_samps will make the estimate of V less precise -- making performance comparisons more suspect

domain = 'rem';

eval_rewds = 3;
eval_gamma = 1;
eval_steps = 10;
eval_samps = 400;

daps = {
    'kla T=1 W=4;' , 'kla' , struct('v_basii', '1a', 'N', 20, 'M', 090, 'T', 1 , 'W', 4, 'gamma', 1);
    'kla T=1 W=3;' , 'kla' , struct('v_basii', '1a', 'N', 20, 'M', 090, 'T', 1 , 'W', 3, 'gamma', 1);
    'kla T=3 W=2;' , 'kla' , struct('v_basii', '1a', 'N', 20, 'M', 090, 'T', 3 , 'W', 2, 'gamma', 1);    
};

[s_1     ] = feval([domain '_random']);
[~,~, t_b] = feval([domain '_transitions']);
[r_i, r_p] = feval([domain '_reward_basii']);

rwds = arrayfun(@(i) get_random_reward_function(r_p, r_i)  , 1:eval_rewds, 'UniformOutput', false)';

for ai = 1:size(daps,1)
    
    [avg_v, var_v] = deal(0,NaN);
    [avg_t, var_t] = deal(0,NaN);
    
    for ri = 1:size(rwds,1)

        desc = daps{ai,1};
        algo = daps{ai,2};
        parm = daps{ai,3};
        rewd = rwds{ri,1};

        feval([domain '_parameters'], parm);

        [policy, t] = feval(algo, domain, rewd);
        [v        ] = expectation_from_simulations(policy, t_b, s_1, rewd, eval_steps, eval_samps, eval_gamma);

        t = sum(t);
        
        avg_v_old = avg_v;
        avg_t_old = avg_t;

        avg_v = (1-1/ri) * avg_v + (1/ri) * v;
        avg_t = (1-1/ri) * avg_t + (1/ri) * t;

        if ri == 1
            var_v = 0;
            var_t = 0;
        else
            var_v = (ri-2)/(ri-1) * var_v + 1/(ri-1) * (v-avg_v)*(v-avg_v_old);
            var_t = (ri-2)/(ri-1) * var_t + 1/(ri-1) * (t-avg_t)*(t-avg_t_old);
        end
    end

    SE_v = sqrt(var_v/size(rwds,1));
    SE_t = sqrt(var_t/size(rwds,1));

    p_results(desc, avg_t, avg_v, SE_t, SE_v);
end

fprintf('\n');

function r_f = get_random_reward_function(r_p, r_i) 
    %r_v = (2*rand(size(r_p,1),1) - 1)' * r_p;
    r_v = 1 - rand(1,size(r_p,2))*2;
    r_f = @(s) r_v(r_i(s));
end

function p_results(desc, avg_t, avg_v, SE_t, SE_v)
    fprintf('%s'               , desc );
    fprintf('\t avg_T = %5.2f;', avg_t);
    fprintf('\t SE_T = %7.3f;' , SE_t );
    fprintf('\t avg_V = %7.3f;', avg_v);
    fprintf('\t SE_V = %7.3f;' , SE_v );
    fprintf('\n');
end