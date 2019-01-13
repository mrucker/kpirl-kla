clear; close all; qs_paths;

%WARNING: The distribution of V is unknown making traditional confidence bounds around mean using SE suspect
%WARNING: reducing eval_samps will make the estimate of V less precise -- making performance comparisons more suspect

domain = 'huge';

eval_rewds = 20;
eval_gamma = .9;
eval_steps = 10;
eval_inits = 30;
eval_samps = 400;

daps = {
    'kla  ' , 'kla'  , struct('N', 50);
    'lspi ' , 'lspi' , struct('N', 30);
    'klspi' , 'klspi', struct('N', 30);
};

[s_1     ] = feval([domain '_random']);
[~,~, t_b] = feval([domain '_transitions']);
[r_i, r_p] = feval([domain '_reward_basii']);

rwds = arrayfun(@(i) get_random_reward_function(r_p, r_i)  , 1:eval_rewds, 'UniformOutput', false)';

for ai = 1:size(daps,1)
    avg_value = 0;
    avg_time  = 0;
    var_value = NaN;
    for ri = 1:size(rwds,1)
        desc = daps{ai,1};
        algo = daps{ai,2};
        parm = daps{ai,3};
        rewd = rwds{ri,1};

        [    parm    ] = feval([domain '_paramaters'], parm);
        [policy, time] = feval(strtrim(algo), domain, rewd);
        [ this_value ] = expectation_from_simulations(policy, t_b, s_1, rewd, eval_steps, eval_samps, eval_gamma);

        avg_value_old = avg_value;
        
        avg_value = (1-1/ri) *avg_value + (1/ri) * this_value;
        avg_time  = (1-1/ri) *avg_time  + (1/ri) * sum(time);
        
        if ri == 2
            var_value = 0;
        end
        
        if ri > 1
            %Welford's online variance algorithm
            var_value = (ri-2)/(ri-1) * var_value + 1/(ri-1) * (this_value-avg_value)*(this_value-avg_value_old);
        end
    end
    p_results(desc, avg_time, avg_value, sqrt(var_value/eval_rewds));
end

fprintf('\n');

function r_f = get_random_reward_function(r_p, r_i) 
    %r_v = [(2*rand(size(r_p,1)-1,1) - 1); 0]' * r_p;
    r_v = [0 1 - rand(1,size(r_p,2)-1)*2];
    r_f = @(s) r_v(r_i(s));
end

function p_results(desc, mn_t, mn_v, SE_v)
    fprintf('%s'              , desc);
    fprintf('\t mn_T = %5.2f;', mn_t);
    fprintf('\t mn_V = %7.3f;', mn_v);
    fprintf('\t SE_V = %7.3f;', SE_v);
    fprintf('\n');
end