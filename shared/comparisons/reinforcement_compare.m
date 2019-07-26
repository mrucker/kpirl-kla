function reinforcement_compare(domain, daps, rewards, metrics, summaries, outputs)

    for dap = daps

        description = dap{1};
        algorithm   = dap{2};
        parameters  = dap{3};

        metric_names  = cellfun(@(metric) metric(), metrics');
        metric_values = zeros(numel(rewards),numel(metrics));

        parfor i = 1:numel(rewards)
            feval([domain '_parameters'], parameters, true);
            [policy, time] = algorithm(domain, rewards{i});
            metric_values(i,:) = cellfun(@(metric) metric(rewards{i},policy,time), metrics');
        end

        summary_names  = cellfun(@(summary) summary(), summaries);
        summary_values = cellfun(@(summary) {summary(metric_values)}, summaries);

        for i = 1:numel(outputs)
            outputs{i}(description, parameters, metric_names, metric_values, summary_names, summary_values);
        end

    end