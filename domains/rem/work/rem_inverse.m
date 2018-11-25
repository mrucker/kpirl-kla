clear; close all; run([fullfile(fileparts(which(mfilename))) '/../../../paths.m']);

rem_paramaters(struct('N',10, 'M',90, 'T',4, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.001));

%linear (that is, Abbeel and Ngs original algorithm)
%kernel = k_dot();

%non-linear, other kernels can be used if desired
kernel = k_gaussian(k_norm(),.6);
%kernel = k_dot();

[reward, state_importance, ~] = kpirl('rem', kernel);

[r_i, r_p] = rem_reward_basii();

r_p * state_importance