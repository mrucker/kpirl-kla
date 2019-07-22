function f = polynomial(degree)

    f = @(features) polynomial_features(features, degree);

end

function f = polynomial_features(features, degree, start)

    if nargin == 2
        start = 1;
    end

    f = vertcat(features(start:size(features,1),:));
    
    if degree > 1
        for i = start:size(features,1)            
            f = vertcat(f, features(i,:) .* polynomial_features(features, degree-1, i));
        end
    end
    
end