function k = k_poly(degree, degree_weight)

    %assert(degree > 0, 'degree must be greater than 0');

    k = @(U,V) (U'*V + degree_weight).^degree;
end