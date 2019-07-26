function f = summaries_to_screen()

    f = @screen_closure;

    function screen_closure(description, parameters, metric_names, metric_values, summary_names, summary_values)
        fprintf('%7s', description);
        
        print_summaries(metric_names, metric_values, summary_names, summary_values);
        print_parameters(parameters);
        
        fprintf('\n');
    end
end

function print_summaries(metric_names, ~, summary_names, summary_values)
    for m = 1:numel(metric_names)
        for s = 1:numel(summary_names)
            fprintf('  %s_%s=%6.2f;', summary_names{s}, metric_names{m}, summary_values{s}(m));
        end
    end
end

function print_parameters(parameters)
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
