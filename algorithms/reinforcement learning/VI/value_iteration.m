function [V,P] = value_iteration(T, R, discount, epsilon, max_iter)

    iter = 0;

    S_N = size(R,1);
    A_N = size(T,2);

    Q = zeros(S_N, A_N);

    if(nargin < 4)
        epsilon = .01;
    end

    if(nargin < 5)
        max_iter = 1000;
    end

    V = zeros(S_N, 001);

    if discount ~= 1
        epsilon = epsilon * (1-discount)/discount; %[(Powell 64) I have no idea why they apply this transformation]
    end;

    done = false;

    while ~done

        v    = V;
        iter = iter + 1;

        for a_i = 1:A_N
            Q(:, a_i) = R + discount*T{a_i}*V;
            %V = max(V, Q(:,a_i)); %I think adding this line makes this closer to the Gauss-Seidel variation (Powell 64)
        end

        [V,P] = max(Q, [], 2);

        d = abs(V-v);
        %max(d)          < epsilon [Checking for convergence. We should only converge on V*.]
        %max(d) - min(d) < epsilon [(Powell 65) The idea is that this gives us an optimal policy though maybe not V*]

        done = max(d) - min(d) < epsilon;
        done = done || iter == max_iter;
    end
end