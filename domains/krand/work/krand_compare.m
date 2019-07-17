clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

%WARNING: The distribution of V is unknown making traditional confidence bounds around mean using SE suspect
%WARNING: reducing eval_samps will make the estimate of V less precise -- making performance comparisons more suspect

domain = 'krand';

rng(1)

eval_rewds = 1;  %How many times it runs KLA
eval_gamma = 1;  %Gamma associated with value function (how much we discount each successive reward)
eval_steps = 20; %How many states does the algorithm generate to see how good the value function is?
eval_samps = 10; %Making this many trajectories

daps = {};

 for n = [20 30]
     for m = [40]
         for t = [25]
             daps(end+1, 1:3) = {sprintf('n=%d,m=%d,t=%d', [n,m,t])', 'kla_mem', struct('v_basis', '1a', 'N', n, 'M', m, 'T', t , 'W', 5, 'gamma', .9)};
         end
     end
 end

algorithm_parameter_compare(domain, daps, @random_linear_reward, eval_rewds, eval_samps, eval_steps, eval_gamma)

function r_f = random_linear_reward(r_i, r_p)
    r_w = 1 - 2 * rand(1,r_p());
    r_f = @(s) r_w * r_p(r_i(s));
end