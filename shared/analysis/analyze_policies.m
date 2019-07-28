function analyze_policies(domain, daps, rewards, attributes, statistics, outputs)

    for dap = daps

        description = dap{1};
        algorithm   = dap{2};
        parameters  = dap{3};

        attribute_names = cellfun(@(attribute) attribute(), attributes');
        statistic_names = cellfun(@(statistic) statistic(), statistics); 

        policies_attributes = cell(1, numel(rewards)) ;

        parfor r = 1:numel(rewards)
            feval([domain '_parameters'], parameters, true);

            [~, ~, policies, times] = algorithm(domain, rewards{r});

            policies_attributes{r} = zeros(numel(policies), numel(attributes))

            for p = 1:numel(policies)
                calculate = @(attribute) attribute(rewards{r}, rewards, policies{p}, policies, times(:,p), times);
                policies_attributes{r}(p,:) = cellfun(calculate, attributes');
            end
        end

        policies_attributes = permute(cat(3, policies_attributes{:}), [1 3 2]);

        for p = 1:size(policies_attributes,1)
            policy_attributes = squeeze(policies_attributes(p,:,:));
            policy_statistics = cellfun(@(statistic) {statistic(policy_attributes)}, statistics);

            for i = 1:numel(outputs)
                outputs{i}(description, parameters, attribute_names, policy_attributes, statistic_names, policy_statistics);
            end
        end
    end