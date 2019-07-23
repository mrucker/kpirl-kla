function new_policy = klsq_mem(samples, policy, new_policy, mu)

    exemplars = ald_analysis(samples, new_policy, mu);

    sampleNumber=length(samples);

    b=zeros(size(exemplars,1), 1);
    A=zeros(size(exemplars,1), size(exemplars,1));

    basis_f = new_policy.basis;
    gamma_t = new_policy.discount;

    parfor i=1:sampleNumber
        k_hat=feval(basis_f, samples(i).state, samples(i).action, exemplars);

        if samples(i).absorb
            A=A+k_hat*k_hat';
        else

            nextaction=policy_function(policy, samples(i).nextstate);

            k_hat_next=feval(policy.basis, samples(i).nextstate, nextaction, exemplars);

            A=A+k_hat*(k_hat'-gamma_t*k_hat_next');
        end

        b=b+samples(i).reward*k_hat;        
    end

    if rank(A) == size(A,1)
        w = A\b;
    else
        w = pinv(A)*b;
    end

    new_policy.weights = w;
    new_policy.exemplars = exemplars;
    
    return
end