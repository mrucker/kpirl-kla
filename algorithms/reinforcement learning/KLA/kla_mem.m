function [policy, time, policies, times] = kla_mem(domain, reward); global fitrsvm_kernel;

    [params      ] = feval([domain '_parameters']);
    [s2f         ] = feval([domain '_features'], 'value');
    [edges, parts] = feval([domain '_discrete'], 'value');
        
    [~, i2d      ] = discrete(s2f, edges, parts);

    if(isa(params.v_kernel,'function_handle'))
        fitrsvm_kernel = params.v_kernel;
        KernelFunction = 'fitrsvm_kernel_caller';
    else
        KernelFunction = params.v_kernel;
    end
    
    %how v_p functions
    %how Q_bar(is) functions
    

    Q_bar = Q_bar_ctor(KernelFunction, i2d, @(is) ones(1,numel(is)));

    [policy, time, policies, times] = kla_core(domain, reward, Q_bar);
end

function f = Q_bar_ctor(K, i2d, G, X, ~)

    if nargin == 2
        [X, ~] = deal([],[]);
    end

    function q = Q_bar(is, qs)

        if(nargin == 0)
            q = X;
        end

        if(nargin == 1)
            q = G(is);
        end

        if(nargin==2)

            x = i2d(is);
            y = qs;

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(y)/1.349;
            end

            m = fitrsvm(x',y' ,'KernelFunction',K, 'BoxConstraint',box_constraint);

            if(any(strcmp(K, ["linear","gaussian","rbf","polynomial"])))
                y = @(is) predict(m, i2d(is)')';
            else
                %for some reason fitrsvm doesn't vectorize custom kernel functions 
                %so I handle predicting manually to take advantage of vectorization
                %https://www.mathworks.com/matlabcentral/answers/516513-fitrsvm-doesn-t-vectorize-my-custom-kernel
                y = @(is) m.Bias + m.Alpha' * feval(K,m.SupportVectors,i2d(is)');
            end
            
            q = Q_bar_ctor(K, i2d, y, is, qs);
        end
    end
    f = @Q_bar;
end