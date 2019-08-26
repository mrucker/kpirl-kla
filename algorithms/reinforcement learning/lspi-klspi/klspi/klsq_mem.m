function new_policy = klsq_mem(samples, new_policy, mu)

    exemplars = ald_analysis(samples, new_policy, mu);

    R_hat             = cell2mat(arrayfun(@(sample) {sample.reward   }, samples'));
    K_hat             = cell2mat(arrayfun(@(sample) {sample.basis    }, samples'));
    K_hat_next        = cell2mat(arrayfun(@(sample) {sample.nextbasis}, samples'));
    K_hat_next_absorb = cell2mat(arrayfun(@(sample) {sample.absorb   }, samples'));
    
    K_hat      = new_policy.affin(K_hat     , exemplars);
    K_hat_next = new_policy.affin(K_hat_next, exemplars) .* ~K_hat_next_absorb;

    k = size(exemplars,1);
    A =zeros(k, k);
    b =zeros(k, 1);
    
    for i=1:length(samples)
        
        r_hat      = R_hat(i,:);
        k_hat      = K_hat(i,:);
        k_hat_next = K_hat_next(i,:);
        
        A = A + k_hat * (k_hat - new_policy.discount * k_hat_next)';
        b = b + k_hat * r_hat;
        
    end

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    new_policy.weights   = w;
    new_policy.exemplars = exemplars;
    new_policy.explore   = 0;

    return
end