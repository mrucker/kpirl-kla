function k = coalesce_if_empty(k,v)
    if isempty(k)
        k = v;
    end
end