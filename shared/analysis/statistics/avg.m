function f = avg()
    
    f = @avg_closure;
    
    function f = avg_closure(metrics)
        if(nargin == 0)
            f = "avg";
        else
            f = mean(metrics);
        end
    end
end

    