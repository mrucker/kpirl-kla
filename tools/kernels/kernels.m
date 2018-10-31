function k = k_polynomial(b,p,c)

    assert( p > 0, 'p must be greater than 0');

    if p == 1
        k = @(x1,x2) b(x1,x2);
    else        
        k = @(x1,x2) 2^(-p)*(b(x1,x2)/b(x1(:,1),x1(:,1)) + c)^p;
    end
end

function k = k_sigmoid(b)
    k = @(x1,x2) tanh(b(x1,x2));
end

function k = k_exponential(b,s)
    k = @(x1,x2) exp(-b(x1,x2)/s);
end

function k = k_gaussian(b,s)
    k = @(x1,x2) exp(-(b(x1,x2).^2)/s);
end

function k = k_anova(d)
    k = @(x1,x2) r_anova(x1,x2,d);
end

function k = r_anova(x1, x2, d)
%pg 301 in Kernel Methods for Pattern Analysis
    n = size(x1,1);
        
    if(n == d)
        k = prod(double(x1 == x2) + 1);
        return;
    end
    
    n = n+1; %to account for n=0;
    d = d+1; %to account for d=0;

    
    DP = zeros(d,n);
    DP(1,:) = 1; %this is d=0;

    for i = 2:d
        for j = i:n
            DP(i,j) = DP(i,j-1) + (x1(j-1)==x2(j-1))*DP(i-1,j-1);
        end
    end
        
    k = sum(DP(:,n));
end

function k = k_hamming()    
    k = @(x1,x2) x1'*x2 + (x1-1)'*(x2-1);
end

function k = k_hamming_inverse()
    k = @(x1,x2) - ((x1-1)'*x2 + x1'*(x2-1));
end

function k = k_norm()
    k = @(x1,x2) x1'*x1 + x2'*x2 - 2*x1'*x2;
end

function k = k_equal(b)    
    k = @(x1,x2) b(x1,x2) == 0;
end
