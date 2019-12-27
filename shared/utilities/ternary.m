function V = ternary(bool, val1, val2)

    if (isfunc(bool) && bool()) || (bool)
        if isfunc(val1)
            V = val1();
        else
            V = val1;
        end
    else
        if isfunc(val2)
            V = val2();
        else
            V = val2;
        end
    end
end

function is = isfunc(a)
    is = isa(a, 'function_handle');
end
