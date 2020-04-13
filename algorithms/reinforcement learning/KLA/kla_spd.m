function [policy, time, policies, times] = kla_spd(domain, reward); global fitrsvm_kernel;
    
    [params      ] = feval([domain '_parameters']);
    [s2f         ] = feval([domain '_features'], 'value');
    [edges, parts] = feval([domain '_discrete'], 'value');
        
    [i2d, d2i    ] = discretes(s2f, edges, parts);

    
    if(isa(params.v_kernel,'function_handle'))
        fitrsvm_kernel = params.v_kernel;
        KernelFunction = 'fitrsvm_kernel_caller';
    else
        KernelFunction = params.v_kernel;
    end

    i2d = i2d(1:d2i());

    Q_dot     = Q_dot_ctor(zeros(1,d2i()));
    Q_bar     = Q_bar_ctor(KernelFunction, i2d, ones(1,d2i()));
    OSA_store = OSA_store_ctor(zeros(6,d2i()));

    [policy, time, policies, times] = kla_core(domain, reward, Q_dot, Q_bar, OSA_store);

    clear k_fitrsvm_kernel
end

function f = Q_dot_ctor(Q)
    function q = Q_dot(is, qs)

        if(nargin == 0)
            q = find(~isnan(Q));
        end

        if(nargin == 1)
            q = Q(is);
        end

        if(nargin==2)
            Q(is) = qs;
            q = @Q_dot;
        end
    end
    f = @Q_dot;
end

function f = Q_bar_ctor(K, v_p, G, X, ~)

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

            X = v_p(:,is);
            Y = qs;

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(Y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(Y)/1.349;
            end

            m = fitrsvm(X', Y', 'KernelFunction',K, 'BoxConstraint',box_constraint);
            
            if(any(strcmp(K, ["linear","gaussian","rbf","polynomial"])))
                y = predict(m, v_p')';
            else
                %for some reason fitrsvm doesn't vectorize custom kernel functions 
                %so I handle predicting manually to take advantage of vectorization
                %https://www.mathworks.com/matlabcentral/answers/516513-fitrsvm-doesn-t-vectorize-my-custom-kernel
                y = m.Bias + m.Alpha' * feval(K,m.SupportVectors,v_p');
            end
            
            q = Q_bar_ctor(K, v_p, y, is, qs);
        end
    end
    f = @Q_bar;
end

function f = OSA_store_ctor(Z)
    function varargout = OSA_store(is, zs)

        if(nargin == 0)
            varargout{1} = find(Z(1,:) ~= 0);
        end

        if(nargin == 1)
            varargout = num2cell(Z(:,is),2);
        end

        if(nargin==2)
            Z(:,is) = zs;

            varargout{1} = OSA_store_ctor(Z);
        end
    end
    f = @OSA_store;
end