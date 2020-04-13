run(fullfile(fileparts(which(mfilename)), 'shared', 'paths.m'));

huge_parameters(struct('N',5, 'M',90, 'T',4, 'W',2, 'steps',10, 'samples',64, 'gamma',.9, 'epsilon',.01, 'r_kernel', k_huge_rwd(.6), 'v_kernel', k_huge_val()));

reward = kpirl_spd('huge');