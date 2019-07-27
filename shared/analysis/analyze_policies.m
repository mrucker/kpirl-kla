function analyze_policies(domain, daps, n_policies, rewards, attributes, statistics, outputs)

    for dap = daps

        description = dap{1};
        algorithm   = dap{2};
        parameters  = dap{3};

        attribute_names = cellfun(@(attribute) attribute(), attributes');
        statistic_names = cellfun(@(statistic) statistic(), statistics);
        
        policies_attributes = zeros(n_policies, numel(rewards),numel(attributes));

        parfor r = 1:numel(rewards)
            feval([domain '_parameters'], parameters, true);

            [~, ~, policies, times] = algorithm(domain, rewards{r});

            for p = 1:n_policies
                calculate = @(attribute) attribute(rewards{r}, rewards, policies{p}, policies, times(:,p), times);
                policies_attributes(p,r,:) = cellfun(calculate, attributes');
            end
        end

        for p = 1:n_policies
            policy_attributes = squeeze(policies_attributes(p,:,:));
            policy_statistics = cellfun(@(statistic) {statistic(policy_attributes)}, statistics);

            for i = 1:numel(outputs)
                outputs{i}(description, parameters, attribute_names, policy_attributes, statistic_names, policy_statistics);
            end
        end
    end