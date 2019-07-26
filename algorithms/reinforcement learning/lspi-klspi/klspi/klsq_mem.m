function new_policy = klsq_mem(samples, policy, new_policy, mu)

    exemplars = ald_analysis(samples, new_policy, mu);

    howmany=length(samples);

    b=zeros(size(exemplars,1), 1);
    A=zeros(size(exemplars,1), size(exemplars,1));

    for i=1:howmany
        k_hat=new_policy.basis(samples(i).state, samples(i).action, exemplars);

        if ~samples(i).absorb
            nextaction=policy_function(policy, samples(i).nextstate);
            k_hat_next=new_policy.basis(samples(i).nextstate, nextaction, exemplars);
        else
            k_hat_next = zeros(size(exemplars,1),1);
        end

        A=A+k_hat*(k_hat'-new_policy.discount*k_hat_next');
        b=b+samples(i).reward*k_hat;
    end

    if rank(A) == size(exemplars,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    new_policy.weights   = w;
    new_policy.exemplars = exemplars;
    new_policy.explore   = 0;

    return
end