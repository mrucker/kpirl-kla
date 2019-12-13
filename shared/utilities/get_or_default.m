function v = get_or_default(struct, fieldname, default)
    if ~isfield(struct,fieldname)
        v = default;
    else
        v = struct.(fieldname);
    end
end