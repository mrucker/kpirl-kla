function k = k_gaussian(b,s)
    %this is probably the most common kernel function
    %some articles define it with a 2 in the denominator (https://en.wikipedia.org/wiki/Radial_basis_function_kernel)
    %other articles exclude the 2 from the denominator (https://scikit-learn.org/stable/modules/metrics.html#polynomial-kernel)
    k = @(x1,x2) exp(-(b(x1,x2).^2)/s^2);
end