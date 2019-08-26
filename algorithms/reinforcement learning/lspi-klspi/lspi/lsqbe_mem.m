function new_policy = lsqbe_mem(samples, new_policy)  

    k = new_policy.basis();
    A = zeros(k, k);
    b = zeros(k, 1);  

    for i=1:length(samples)

        phi     = samples(i).nextbasis;
        nextphi = samples(i).nextbasis * ~samples(i).absorb;

        A = A + (phi - new_policy.discount * nextphi) * (phi - new_policy.discount * nextphi)';
        b = b + (phi - new_policy.discount * nextphi) * samples(i).reward;

    end

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    new_policy.weights = w;
    new_policy.explore = 0;

end
  
