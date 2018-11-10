function k = k_hamming(isZero)
    if(isZero==0)
        k = @(x1,x2) - ((x1-1)'*x2 + x1'*(x2-1));
    else
        k = @(x1,x2) x1'*x2 + (x1-1)'*(x2-1);
    end
end