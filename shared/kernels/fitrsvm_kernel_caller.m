function G = fitrsvm_kernel_caller(U,V); global fitrsvm_kernel;
    %when using fitrsvm with custom kernels the kernel has to be .m file on the path
    %this means we can't specify kernels as a parameter anymore, to get around this
    %limitation we use this method and set a global variable before calling fitrsvm
    G = fitrsvm_kernel(U',V');
end