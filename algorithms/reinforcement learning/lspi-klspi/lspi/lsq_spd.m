function new_policy = lsq_spd(samples, new_policy)

    R_hat             = cell2mat(arrayfun(@(sample) {sample.reward   }, samples'));
    K_hat             = cell2mat(arrayfun(@(sample) {sample.basis    }, samples'));
    K_hat_next        = cell2mat(arrayfun(@(sample) {sample.nextbasis}, samples'));
    K_hat_next_absorb = cell2mat(arrayfun(@(sample) {sample.absorb   }, samples'));

    K_hat_next = K_hat_next .* ~K_hat_next_absorb;

    A = K_hat' * (K_hat - new_policy.discount * K_hat_next);
    b = K_hat' * R_hat;

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    new_policy.weights = w;
    new_policy.explore = 0;

end