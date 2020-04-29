function test_indexable(filler, n_rows, indexable)

    lastwarn(''); %reset the warning state
    
    disp(func2str(indexable) + " beginning tests")
    
    v1 = randi(100,n_rows,1);
    v2 = randi(100,n_rows,1);
    v3 = randi(100,n_rows,1);
    v4 = randi(100,n_rows,1);

    try
        [K,V] = indexable();

        assert_warning(isempty(K) && isempty(V), "get all incorrect before first insert");
        assert_warning(isequaln(indexable(11), filler), "get key incorrect before first insert");
    catch
        warning("failed before first insert");
    end

    try
        indexable(10,v1);

        [K,V] = indexable();

        assert_warning(isequaln(K, 10), "get all keys incorrect after first insert");
        assert_warning(isequaln(V, v1), "get all vals incorrect after first insert");
        assert_warning(isequaln(indexable(10), v1), "get inserted key incorrect after first insert");
        assert_warning(isequaln(indexable(11), filler), "get not-inserted key incorrect after first insert");
        assert_warning(isequaln(indexable([10, 11, 12]), [v1 filler, filler]), "get vector key incorrect after first insert");

    catch
        warning("failed on first insert");
    end

    try
        indexable(12,v2);
        
        [K,V] = indexable();
        
        assert_warning(isequaln(K, [10 12]), "indexable get all keys incorrect after second insert");
        assert_warning(isequaln(V, [v1 v2]), "indexable get all vals incorrect after second insert");
        assert_warning(isequaln(indexable(10),v1), "indexable get inserted keys incorrect after second insert");
        assert_warning(isequaln(indexable(12),v2), "indexable get inserted keys incorrect after second insert");
        assert_warning(isequaln(indexable(13),filler), "indexable get not-inserted key incorrect after second insert");
        assert_warning(isequaln(indexable([10,13,12]), [v1, filler, v2]), "indexable get vector key incorrect after second insert");
    catch
        warning("failed on second insert");
    end
    
    try
        indexable([14 12],[v3 v4]);
        
        [K,V] = indexable();
        
        assert_warning(isequaln(K, [10 12 14]), "indexable get all keys incorrect after multi-insert");
        assert_warning(isequaln(V, [v1 v4 v3]), "indexable get all vals incorrect after multi-insert");
        assert_warning(isequaln(indexable(10),v1), "indexable get inserted keys incorrect after multi-insert");
        assert_warning(isequaln(indexable(12),v4), "indexable get inserted keys incorrect after multi-insert");
        assert_warning(isequaln(indexable(14),v3), "indexable get inserted keys incorrect after multi-insert");
        assert_warning(isequaln(indexable(13),filler), "indexable get not-inserted key incorrect multi-second insert");
        assert_warning(isequaln(indexable([12,14,10]), [v4, v3, v1]), "indexable get vector key incorrect after multi-insert");
    catch
        warning("failed on second insert");
    end

    if isempty(lastwarn)
        disp(func2str(indexable) + " passed all tests")
    end
end