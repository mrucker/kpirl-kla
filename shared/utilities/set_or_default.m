function struct = set_or_default(struct, default)

    % Step over all fields in the defaults structure.
    for default_fieldname = fieldnames(default)'
        if ~isfield(struct, default_fieldname)
            struct.(default_fieldname{1}) = default.(default_fieldname{1});
        end
    end

end