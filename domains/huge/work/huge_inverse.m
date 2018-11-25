clear; close all; run([fullfile(fileparts(which(mfilename))) '/../../../qs_paths.m']);

huge_paramaters(struct('N',30, 'M',90, 'T',3, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.001, 'kernel', k_gaussian(k_norm(), .6)));

[reward, ~, state_importance] = pirl('huge');

[r_i, r_p] = rem_reward_basii();

r_p * state_importance
