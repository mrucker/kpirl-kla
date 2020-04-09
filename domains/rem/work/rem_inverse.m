run(fullfile(fileparts(which(mfilename)), '..', '..', '..', 'shared', 'paths.m'));

rem_parameters(struct('N',10, 'M',90, 'T',4, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.1, 'r_kernel',k_dot()));

rng(10);

disp('')
disp('kpirl_mem')
[~, ~] = kpirl_mem('rem');

disp('')
disp('kpirl_spd')
[~, ~] = kpirl_spd('rem');