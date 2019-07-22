function [b_i, b_p] = single_basis()

    b_i = @input2index;    
    b_p = @input2basis;
    

    function levels = input2index(input)
        if nargin == 0
            levels = 1;
        else
            levels = ones(1, size(input,2));
        end
    end

    function basis = input2basis(input)
        if nargin == 0
            basis = 1;
        else
            basis = ones(1, size(input,2));
        end
    end
end