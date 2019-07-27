function s = struct2string(struct)
    fields       = fieldnames(struct);
    field_values = strings(1, numel(fields));

    for i = 1:numel(fields)
        field = fields{i};
        value = struct.(field);
        field_values(i) = sprintf('%s=%s', field, value2string(value));
    end

    s = sprintf('{ %s }', join(field_values, ", "));
end