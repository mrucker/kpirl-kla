function f = statistics_to_screen()

    f = @screen_closure;

    function screen_closure(description, parameters, attribute_names, attribute_values, statistic_names, statistic_values)
        fprintf('%7s', description);

        disp_statistics(attribute_names, attribute_values, statistic_names, statistic_values);
        disp_parameters(parameters);

        fprintf('\n');
    end
end

function disp_statistics(attribute_names, ~, statistic_names, statistic_values)
    for a = 1:numel(attribute_names)
        for s = 1:numel(statistic_names)
            fprintf('  %s_%s=%6.2f;', statistic_names{s}, attribute_names{a}, statistic_values{s}(a));
        end
    end
end

function disp_parameters(parameters)
    fields       = fieldnames(parameters);
    field_values = strings(1, numel(fields));

    for i = 1:numel(fields)
        field = fields{i};
        value = parameters.(field);
        field_values(i) = sprintf('%s=%s', field, val2str(value));
    end

    fprintf(' { %s }', join(field_values, ", "));
end

function str = val2str(val)
    if (isa(val, 'function_handle'))
        str = func2str(val);
    else
        str = string(val);
    end
end
