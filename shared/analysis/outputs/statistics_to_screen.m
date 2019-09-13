function f = statistics_to_screen()

    f = @screen_closure;

    function screen_closure(description, parameters, attribute_names, attribute_values, statistic_names, statistic_values)
        fprintf('%s ', description);

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
    fprintf(' %s', struct2string(parameters));
end