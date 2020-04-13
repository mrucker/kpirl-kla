function [reward_function, time_measurements] = pirl_mem(domain)

    param = feval([domain '_parameters']);
    param.r_kernel = k_dot();
    feval([domain '_parameters'], param);

    [reward_function, time_measurements] = kpirl_mem(domain);
end