function [reward_function, time_measurements] = pirl_spd(domain)

    param =  feval([domain '_parameters']);
    param.kernel = k_dot();
    feval([domain '_parameters'], param, true);

    [reward_function, time_measurements] = kpirl_spd(domain);
end