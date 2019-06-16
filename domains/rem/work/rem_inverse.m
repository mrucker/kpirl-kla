clear; close all; run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'qs_paths.m'));

rem_parameters(struct('N',10, 'M',90, 'T',4, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.1, 'kernel',k_dot));

rng(10);
[~, ~] = kpirl_mem('rem');

rng(10);
[~, ~] = kpirl_spd('rem');