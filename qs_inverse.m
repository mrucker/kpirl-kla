run(fullfile(fileparts(which(mfilename)), 'shared', 'paths.m'));

huge_parameters(struct('N',5, 'M',90, 'T',4, 'W',2, 'steps',10, 'samples',64, 'gamma',.9, 'epsilon',.001, 'kernel', k_gaussian(k_norm(), .6)));

reward = kpirl_mem('huge');