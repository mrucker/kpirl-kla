clear; paths; close all

huge_paramaters = (struct('N',50, 'M',90, 'S',4, 'W',4, 'steps',10, 'samples',500, 'gamma',.9, 'epsilon',.001));

reward = kpirl('huge', get_kernel(5));

function kernel = get_kernel(kernel_id)
    p = 2;
    c = 1;
    s = .6;

    switch kernel_id
        case 1
            b = k_dot();
        case 2
            b = k_polynomial(k_hamming(1),p,c);
        case 3
            b = k_hamming(0);
        case 4
            b = k_equal(k_norm());
        case 5
            b = k_gaussian(k_norm(),s);
        case 6
            b = k_exponential(k_norm(),s);
        case 7
            b = k_anova(size(x1,1));
        case 8
            b = k_exponential_compact(k_norm(),s);
    end

    kernel = b;
end