run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'shared', 'paths.m'));

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'huge';

n_rewds = 8;
n_samps = 64;
n_steps = 10;
  gamma = 0.9;

rewards    = random_linear_reward(domain, n_rewds, @(n) [1 - 2 * rand(1,n-1) 0]);
attributes = { policy_time() policy_value(domain, n_samps, n_steps, gamma) };
statistics = { avg() SEM() med() };
outputs    = { statistics_to_screen() };

daps = {
    %generate a policy using kla_spd and features '1b' (aka, shared/single_basis) which gives a policy of random actions.
    'random'  , @kla_spd, struct('N', 30, 'M', 01 , 'T', 01, 'v_feats', '1b', 'W', 00);

    %generate a policy using kla_spd and features '1a' (this kla implementation decreases computation by increasing memory use)
    'kla_spd' , @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_feats', '1a', 'W', 02, 'explore', 0, 'target', 0, 'smooth', 1);
    'kla_spd' , @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_feats', '1a', 'W', 02, 'explore', 1, 'target', 0, 'smooth', 1);
    'kla_spd' , @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_feats', '1a', 'W', 02, 'explore', 2, 'target', 0, 'smooth', 1);

    %generate a policy using kla_mem and features '1a' (this kla implementation decreases memory use by increasing computation)
    %'kla_mem' , @kla_mem, struct('N', 30, 'M', 90 , 'T', 04, 'v_feats', '1a', 'W', 02, 'explore', 1, 'bootstrap', 0);

    %generate a policy using lspi and features '1a' with a second order polynomial basis
    %'lspi'    , @lspi   , struct('N', 30, 'M', 90 , 'T', 06, 'v_feats', '1a', 'resample', true, 'basis', poly_basis(2));
    %'lspi'    , @lspi   , struct('N', 30, 'M', 90 , 'T', 20, 'v_feats', '1a', 'resample', true, 'basis', poly_basis(2));

    %generate a policy using klspi and features '1a' with the provided kernel function
    %'klspi'   , @klspi  , struct('N', 30, 'M', 90 , 'T', 06, 'v_feats', '1a', 'resample', true, 'kernel', k_gaussian(k_norm(),1.00), 'mu', 0.3);
    %'klspi'   , @klspi  , struct('N', 30, 'M', 90 , 'T', 20, 'v_feats', '1a', 'resample', true, 'kernel', k_gaussian(k_norm(),1.00), 'mu', 0.3);
}';

a = tic;

analyze_policy(domain, daps, rewards, attributes, statistics, outputs);

toc(a);