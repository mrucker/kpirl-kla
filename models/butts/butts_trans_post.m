function s2 = butts_trans_post(s1, a)

    max_length = 40;
    
    s2 = s1;
    
    if(size(s1,1)/2 >= max_length)
        s2 = circshift(s1,-2,1);
        s2(39:40) = a;
    else
        s2 = vertcat(s2,a);
    end
end