function f = ald_basis(mu, kernel)

    function b = ald_basis_constructor(samples)

        exemplars = ald_analysis(samples, mu, kernel);

        b = @(features) kernel(exemplars,features);
    end

    f = @ald_basis_constructor;

end

function exemplars = ald_analysis(samples, mu, kernel)

    exemplars = samples(1).feats;

    K_t   = kernel(exemplars, exemplars);
    K_Inv = K_t^-1;

    for i=1:length(samples)

        current_features = samples(i).feats;

        k_t = kernel(exemplars       , current_features);
        k_tt= kernel(current_features, current_features);

        c_t = K_Inv*k_t;
        d_t = k_tt-k_t'*c_t;

        %in theory K_t == kernel(exemplars, exemplars) and K_Inv == K_t^-1. However, because we use iterative updates
        %to determine K_t and K_Inv each time we add an exemplar rather than recalculating then from scratch our matrices
        %will deviate slightly from the full recalculation. Thus why we make sure no single element deviates by more than .00001.
        %Calculating kernel(exemplars, exemplars)^-1 for our check is duplicate work so we usually leave it commented.
        % assert(max(abs(kernel(exemplars, exemplars) - K_t), [], 'all') < .0001)
        % assert(max(abs(K_t^-1 - K_Inv), [], 'all') < .00001)

        if  mu <= d_t

            %in theory d_t is the squared distance of our optimization program and so it should always be >= 0
            %in practice though sometimes the value of d_t can be slightly < 0 due to numerical approximation
            %if d_t is ever considerably below 0 (i.e., <= -.0001) then something is wrong with the ALD analysis
            assert(d_t > -.0001);

            exemplars   = horzcat(exemplars, current_features);
            n_exemplars = size(exemplars,2);

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