function k = k_sigmoid(b)
    k = @(x1,x2) tanh(b(x1,x2));
end