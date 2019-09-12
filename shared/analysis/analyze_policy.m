function analyze_policy(domain, daps, rewards, attributes, statistics, outputs)

    for dap = daps

        description = dap{1};
        algorithm   = dap{2};
        parameters  = dap{3};

        attribute_names  = cellfun(@(attribute) attribute(), attributes');
        statistic_names  = cellfun(@(statistic) statistic(), statistics);

        policy_attributes = zeros(numel(rewards),numel(attributes));
        
        fprintf([description repmat('.',1,numel(rewards)) '\n']);
        fprintf([description '\n']);
        
        parfor r = 1:numel(rewards)
            
            fprintf('\b|\n');
            
            feval([domain '_parameters'], parameters, true);

            [policy, time, policies, times] = algorithm(domain, rewards{r});

            calculate = @(attribute) attribute(rewards{r}, rewards, policy, policies, time, times);
            policy_attributes(r,:) = cellfun(calculate, attributes');
        end

        policy_statistics = cellfun(@(statistic) {statistic(policy_attributes)}, statistics);

        for i = 1:numel(outputs)
            outputs{i}(description, parameters, attribute_names, policy_attributes, statistic_names, policy_statistics);
        end

    end