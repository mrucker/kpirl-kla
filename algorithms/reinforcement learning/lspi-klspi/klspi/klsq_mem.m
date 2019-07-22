function new_policy = klsq_mem(samples, policy, new_policy, mu)

    [Dic_t, Dic_dim] = ald_analysis(samples, new_policy, mu);

    sampleNumber=length(samples);

    b=zeros(Dic_dim, 1);
    A=zeros(Dic_dim, Dic_dim);

    basis_f = new_policy.basis;
    gamma_t = new_policy.discount;
    
    parfor i=1:sampleNumber
        k_hat=feval(basis_f, samples(i).state, samples(i).action, Dic_t);

        if samples(i).absorb
            A=A+k_hat*k_hat';
        else

            nextaction=policy_function(policy, samples(i).nextstate);

            k_hat_next=feval(policy.basis, samples(i).nextstate, nextaction, Dic_t);

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
    new_policy.dic     = Dic_t;
    
    return
end