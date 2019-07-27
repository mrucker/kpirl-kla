function reinforcement_compare(domain, daps, rewards, attributes, statistics, outputs)

    for dap = daps

        description = dap{1};
        algorithm   = dap{2};
        parameters  = dap{3};

        metric_names  = cellfun(@(metric) metric(), attributes');
        metric_values = zeros(numel(rewards),numel(attributes));

        parfor i = 1:numel(rewards)
            feval([domain '_parameters'], parameters, true);
            [policy, time] = algorithm(domain, rewards{i});
            metric_values(i,:) = cellfun(@(metric) metric(rewards{i},policy,time), attributes');
        end

        summary_names  = cellfun(@(summary) summary(), statistics);
        summary_values = cellfun(@(summary) {summary(metric_values)}, statistics);

        for i = 1:numel(outputs)
            outputs{i}(description, parameters, metric_names, metric_values, summary_names, summary_values);
        end

    end