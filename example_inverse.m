clear; close all; paths;

huge_paramaters(struct('N',30, 'M',90, 'T',3, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.001));

%linear (this would be Abbeel and Ngs original algorithm)
%kernel = k_dot();

%non-linear (other kernels could also be used if desired)
kernel = k_gaussian(k_norm(), .6);

reward = kpirl('huge', kernel);