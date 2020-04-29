function assert_warning(cond, msg)
    if(~cond)
        warning(msg);
    end
end
