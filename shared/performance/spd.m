function f = spd(indexable_interface)
    a = indexable_interface();
    f = @(is) a(:,is);
end