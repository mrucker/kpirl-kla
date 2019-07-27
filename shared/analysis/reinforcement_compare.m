function reinforcement_compare(domain, daps, rewards, attributes, statistics, outputs)

    for dap = daps

        description = dap{1};
        algorithm   = dap{2};
        parameters  = dap{3};

        attribute_names  = cellfun(@(attribute) attribute(), attributes');
        attribute_values = zeros(numel(rewards),numel(attributes));

        parfor i = 1:numel(rewards)
            feval([domain '_parameters'], parameters, true);
            [policy, time, policies, times] = algorithm(domain, rewards{i});
            attribute_values(i,:) = cellfun(@(attribute) attribute(rewards{i},rewards,policy,policies,time,times), attributes');
        end

        statistic_names  = cellfun(@(statistic) statistic(), statistics);
        statistic_values = cellfun(@(statistic) {statistic(attribute_values)}, statistics);

        for i = 1:numel(outputs)
            outputs{i}(description, parameters, attribute_names, attribute_values, statistic_names, statistic_values);
        end

    end