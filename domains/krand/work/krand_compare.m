run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'shared', 'paths.m'));

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'krand';

n_rewds = 10;
n_samps = 64;
n_steps = 10;
  gamma = .9;

rewards    = random_linear_reward(domain, n_rewds);
attributes = { policy_time() policy_value(domain, n_samps, n_steps, gamma) };
statistics = { avg() SEM() med() };
outputs    = { statistics_to_screen() };

ns = [20 30];
ms = 40;
ts = 25;

daps = cell(3,numel(ns)*numel(ms)*numel(ts));
i    = 0;

for n = ns
     for m = ms
         for t = ts
             i = i+1;
             daps(:,i) = {sprintf('n=%d,m=%d,t=%d', [n,m,t]); @kla_mem; struct('v_basis', '1a', 'N', n, 'M', m, 'T', t , 'W', 5, 'gamma', .9)};
         end
     end
 end

analyze_policy(domain, daps, rewards, attributes, statistics, outputs);