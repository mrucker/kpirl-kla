clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

rem_paramaters(struct('N',10, 'M',90, 'T',4, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.001, 'kernel',k_gaussian(k_norm(),.6)));

[reward, ~, state_importance] = kpirl('rem');

[r_i, r_p] = rem_reward_basii();

r_p * state_importance
