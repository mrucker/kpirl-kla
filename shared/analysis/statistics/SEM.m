function f = SEM()

    f = @SEM_closure;
    
    function f = SEM_closure(metrics)
        if(nargin == 0)
            f = "SEM";
        else
            f = sqrt(var(metrics)/size(metrics,1));
        end
    end
end