function new_policy = lsqbe_spd(samples, new_policy)

    Rhat     = cell2mat(arrayfun(@(sample) {sample.reward                    }, samples'));
    Phihat   = cell2mat(arrayfun(@(sample) {sample.basis                     }, samples'));
    PiPhihat = cell2mat(arrayfun(@(sample) {sample.nextbasis * ~sample.absorb}, samples'));

    A = (Phihat - new_policy.discount * PiPhihat)' * (Phihat - new_policy.discount * PiPhihat);
    b = (Phihat - new_policy.discount * PiPhihat)' * Rhat;

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    new_policy.weights = w;
    new_policy.explore = 0;
  
end
  
