function k = k_exponential(b,s)
    %http://crsouza.com/2010/03/17/kernel-functions-for-machine-learning-applications/#exponential
    %WARNING!! doesn't seem to be widely recognized beyond the above link though
    k = @(x1,x2) exp(-b(x1,x2)./s);
end