function [policy, time, policies, times] = kla_spd(domain, reward)

    [v_i, v_p] = feval([domain '_value_features']);

    v_p = v_p(1:v_i());

    Q_dot     = Q_dot_ctor(zeros(1,v_i()));
    Q_bar     = Q_bar_ctor(v_p, ones(1,v_i()));
    OSA_store = OSA_store_ctor(zeros(6,v_i()));

    [policy, time, policies, times] = kla_core(domain, reward, Q_dot, Q_bar, OSA_store);

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

function f = Q_bar_ctor(v_p, G, X, ~)

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

            x = v_p(:,is);
            y = qs;

            %https://www.mathworks.com/help/stats/fitrsvm.html#busljl4-BoxConstraint
            if iqr(y) < .0001
                box_constraint = 1;
            else
                box_constraint = iqr(y)/1.349;
            end

            m = fitrsvm(x',y' ,'KernelFunction','rbf', 'BoxConstraint',box_constraint, 'Standardize',true);

            q = Q_bar_ctor(v_p, predict(m, v_p')', is, qs);
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