clear; paths; close all;

huge_paramaters(struct('N',50, 'M',90, 'T',4, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.001));

%linear (that is, Abbeel and Ngs original algorithm)
%kernel = k_dot();

%non-linear, other kernels can be used if desired
kernel = k_gaussian(k_norm(),.6);

reward = kpirl('huge', kernel);