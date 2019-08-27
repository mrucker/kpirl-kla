function exemplars = ald_analysis(samples, policy, mu)

    exemplars = policy.basis(samples(1).state, samples(2).action);

    K_t   = policy.affin(exemplars, exemplars);
    K_Inv = K_t^-1;

    for i=1:length(samples)

        state  = samples(i).state;
        action = samples(i).action;

        current_features = policy.basis(state, action);

        k_t = policy.affin(current_features, exemplars)';
        k_tt= policy.affin(current_features, current_features);

        c_t = K_Inv*k_t;
        d_t = k_tt-k_t'*c_t;

        %in theory K_t == policy.affin(exemplars, exemplars) and K_Inv == K_t^-1. However, because we use iterative updates
        %to determine K_t and K_Inv each time we add an exemplar rather than recalculating then from scratch our matrices
        %will deviate slightly from the full recalculation. Thus why we make sure no single element deviates by more than .00001.
        %Calculating policy.affin(exemplars, exemplars)^-1 for our check is duplicate work so we usually leave it commented.
        % assert(max(abs(policy.affin(exemplars, exemplars) - K_t), [], 'all') < .0001)
        % assert(max(abs(K_t^-1 - K_Inv), [], 'all') < .00001)

        if  mu <= d_t

            %in theory d_t is the squared distance of our optimization program and so it should always be >= 0
            %in practice though sometimes the value of d_t can be slightly < 0 due to numerical approximation
            %if d_t is ever considerably below 0 (i.e., <= -.0001) then something is wrong with the ALD analysis
            assert(d_t > -.0001);

            exemplars   = vertcat(exemplars, current_features);
            n_exemplars = size(exemplars,1);

            temp=-c_t/d_t;

            K_Inv = K_Inv+c_t*transpose(c_t)/d_t;
            K_Inv = update_matrix( K_Inv, temp, temp, 1/d_t, n_exemplars-1, n_exemplars-1, n_exemplars, n_exemplars);           
            K_t   = update_matrix(   K_t,  k_t,  k_t,     1, n_exemplars-1, n_exemplars-1, n_exemplars, n_exemplars);
        end
    end 
end

function  Mat_new  = update_matrix(A_t, a_t, b_t, c_t, row_dim1, col_dim1, row_dim2, col_dim2)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Mat_new=zeros(row_dim2, col_dim2);
    Mat_new(1:row_dim1, 1:col_dim1) = A_t;
    if (col_dim2>col_dim1)
       Mat_new(1:row_dim1, col_dim2) = a_t;
    end
    if  (row_dim2>row_dim1)
        Mat_new(row_dim2, 1:col_dim1) = b_t';
    end
    if row_dim2>row_dim1 && col_dim2>col_dim1
       Mat_new(row_dim2, col_dim2) = c_t;
    end

end