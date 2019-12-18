function f = ident_basis()

    function b = ident_basis_constructor(~)
        b = @(features) features;
    end

    f = @ident_basis_constructor;

end