function [M,I] = randargmax(objective,arguments)

    if nargin == 1
        values = arguments;
    else
        values = objective(arguments);
    end

    assert(isvector(values));

    I = find(values == max(values));
    I = I(randi(numel(I)));
    M = arguments(:,I);
end
