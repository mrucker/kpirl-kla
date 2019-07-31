clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

%WARNING: reducing n_rewds will make the estimate of E[V|DAP  ] less precise causing performance comparisons to be more suspect
%WARNING: reducing n_samps will make the estimate of E[V|DAP,R] less precise causing performance comparisons to be more suspect

domain = 'huge';

for i = 1:200

    n_rewds = 4;
    n_samps = 64;
    n_steps = 10;
      gamma = .9;

    rewards    = random_linear_reward(domain, n_rewds, @(n) [1 - 2 * rand(1,n-1) 0]);
    attributes = { policy_iteration_index() policy_value(domain, n_samps, n_steps, gamma) policy_time() };
    statistics = { };
    outputs    = { attributes_to_file("kla.csv") };

    daps = {
        %'random'           , @kla_spd, struct('N', 30, 'M', 01 , 'T', 01, 'v_basis', '1b', 'W', 00);
        'kla-explore=0-W=0', @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 00, 'explore', 0);
        'kla-explore=0-W=1', @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 01, 'explore', 0);
        'kla-explore=0-W=2', @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 02, 'explore', 0);
        'kla-explore=1-W=0', @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 00, 'explore', 1);
        'kla-explore=1-W=1', @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 01, 'explore', 1);
        'kla-explore=1-W=2', @kla_spd, struct('N', 30, 'M', 90 , 'T', 04, 'v_basis', '1a', 'W', 02, 'explore', 1);
    }';

    disp(i);

    a = tic;

    analyze_policies(domain, daps, rewards, attributes, statistics, outputs);

    toc(a);
end