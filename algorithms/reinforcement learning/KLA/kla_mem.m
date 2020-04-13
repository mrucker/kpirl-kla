function [policy, time, policies, times] = kla_mem(domain, reward); global fitrsvm_kernel;

    [params      ] = feval([domain '_parameters']);
    [s2f         ] = feval([domain '_features'], 'value');
    [edges, parts] = feval([domain '_discrete'], 'value');
        
    [i2d         ] = discretes(s2f, edges, parts);

    if(isa(params.v_kernel,'function_handle'))
        fitrsvm_kernel = params.v_kernel;
        KernelFunction = 'fitrsvm_kernel_caller';
    else
        KernelFunction = params.v_kernel;
    end

    Q_dot     = Q_dot_ctor(containers.Map('KeyType','double','ValueType','double'));
    Q_bar     = Q_bar_ctor(KernelFunction, i2d, @(is) ones(1,numel(is)));
    OSA_store = OSA_store_ctor(containers.Map('KeyType','double','ValueType','any'));

    [policy, time, policies, times] = kla_core(domain, reward, Q_dot, Q_bar, OSA_store);
end

function f = Q_dot_ctor(Q)
    function q = Q_dot(is, qs)

        if(nargin == 0)
            q = keys(Q);
        end

        if(nargin == 1)
            if ~iscell(is)
                is = num2cell(is');
            end

            if ~isKey(Q,is)
                q = 0;
            else
                q = cell2mat(values(Q,is));
            end
        end

        if(nargin==2)
            Q(is) = qs;
            q = @Q_dot;
        end
    end
    f = @Q_dot;
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

function f = OSA_store_ctor(Z)
    function varargout = OSA_store(is, zs)

        if(nargin == 0)
            varargout{1} = cell2mat(keys(Z));
        end

        if(nargin == 1)
            if isempty(is)
                varargout = cell(1,6);
            else
                
                if ~iscell(is)
                    is = num2cell(is);
                end

                is_key  = isKey(Z,is);
                is_keys = is(is_key);

                z = zeros(6, numel(is));

                z(:,is_key) = cell2mat(values(Z, is_keys));

                varargout = num2cell(z,2);

            end
        end

        if(nargin==2)
            Z(is) = zs;

            varargout{1} = OSA_store_ctor(Z);
        end
    end
    f = @OSA_store;
end