function weights = lsq_mem(samples, basis, discount)

    k = size(basis(samples(1).feats),1);
    A = zeros(k, k);
    b = zeros(k, 1);  

    for i=1:length(samples)

        phi      = basis(samples(i).feats);
        phi_next = basis(samples(i).nextfeats) * ~samples(i).absorb;

        A = A + phi * (phi - discount * phi_next)';
        b = b + phi * samples(i).reward;

    end

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    weights = w;
end
  
