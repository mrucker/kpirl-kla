function weights = lsq_spd(samples, basis, discount)

    R_hat             = cell2mat(arrayfun(@(sample) {sample.reward   }, samples));
    K_hat             = cell2mat(arrayfun(@(sample) {sample.feats    }, samples));
    K_hat_next        = cell2mat(arrayfun(@(sample) {sample.nextfeats}, samples));
    K_hat_next_absorb = cell2mat(arrayfun(@(sample) {sample.absorb   }, samples));

    K_hat      = basis(K_hat);
    K_hat_next = basis(K_hat_next) .* ~K_hat_next_absorb;

    A = K_hat * (K_hat - discount * K_hat_next)';
    b = K_hat * R_hat';

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end
    
    weights = w;
end