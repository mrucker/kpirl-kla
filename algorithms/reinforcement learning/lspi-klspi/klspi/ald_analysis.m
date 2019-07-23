function exemplars = ald_analysis(samples, policy, mu)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    n_samples   = length(samples);   % number of data samples  

    exemplars   = feval(policy.basis, samples(1).state, samples(1).action);
    n_exemplars = size(exemplars,1);

    k_tt=feval(policy.basis, samples(1).state, samples(1).action, exemplars); 

    K_Inv=zeros(n_exemplars, n_exemplars);
    K_Inv(1,1)=1.0/k_tt;

    K_t=zeros(1,1);

    for i=1:n_samples

        state=samples(i).state;
        action=samples(i).action;

        current_feature=feval(policy.basis, state, action);

        k_t = feval(policy.basis, state, action, exemplars);
        k_tt= feval(policy.basis, state, action, current_feature);

        c_t = K_Inv*k_t';
        d_t = k_tt-k_t*c_t;

        %note, the author's paper doesn't indicate that the abs of d_t should be used
        if  mu <= abs(d_t)

            exemplars   = vertcat(exemplars, current_feature);
            n_exemplars = size(exemplars,1);

            %% K_Inv(t)=[ K_Inv(t-1)+a_t*a_t'/delta,  -a_t/delta ]
            %%          [   -a_t'/delta ,                 1/delta]
            K_Inv=K_Inv+c_t*transpose(c_t)/d_t;

            temp=-c_t/d_t;

            K_Inv= update_matrix( K_Inv, temp, temp, 1/d_t, n_exemplars-1, n_exemplars-1, n_exemplars, n_exemplars);
            %% Update K_t= [K_(t-1),  k_t; k_t',  1]
            K_t  = update_matrix(K_t, k_t, k_t, 1, n_exemplars-1,n_exemplars-1, n_exemplars, n_exemplars);
        end  %% End of if-else 
    end  %% End of for 
end

function  Mat_new  = update_matrix( A_t, a_t, b_t, c_t, row_dim1, col_dim1, row_dim2, col_dim2)

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

