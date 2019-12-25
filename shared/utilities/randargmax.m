function [M,I] = randargmax(A,f)

    if nargin == 1
        values = A;
    else
        values = f(A);
    end

    assert(isvector(values));

    I = find(values == max(values));
    I = I(randi(numel(I)));    
    M = A(:,I);
end
