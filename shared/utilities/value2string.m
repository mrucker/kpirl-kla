function str = value2string(value)
    if (isa(value, 'function_handle'))
        str = func2str(value);
    else
        str = string(value);
    end
end
