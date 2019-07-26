clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'krand';

n_rewds = 10;
n_samps = 64;
n_steps = 10;
  gamma = .9;

rewards = random_linear_reward(domain, n_rewds);
metrics = { policy_time()  policy_value(domain, n_samps, n_steps, gamma) };
summary = { avg() SEM() med() };
outputs = { summaries_to_screen() };

daps = {};

for n = [20 30]
     for m = 40
         for t = 25
             daps(1:3,end+1) = {sprintf('n=%d,m=%d,t=%d', [n,m,t])'; @kla_mem; struct('v_basis', '1a', 'N', n, 'M', m, 'T', t , 'W', 5, 'gamma', .9)};
         end
     end
 end

reinforcement_compare(domain, daps, rewards, metrics, summary, outputs);