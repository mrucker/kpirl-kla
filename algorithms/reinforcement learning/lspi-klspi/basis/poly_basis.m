function f = poly_basis(degree)

    function b = poly_basis_constructor(~)
        b = @(features) polynomial_transform(features, degree);
    end

    f = @poly_basis_constructor;

end

function f = polynomial_transform(features, degree, start)

    if nargin == 2
        start = 1;
    end

    f = vertcat(features(start:size(features,1),:));
    
    if degree > 1
        for i = start:size(features,1)            
            f = vertcat(f, features(i,:) .* polynomial_transform(features, degree-1, i));
        end
    end
    
end