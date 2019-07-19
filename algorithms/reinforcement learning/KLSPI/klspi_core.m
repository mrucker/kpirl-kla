function [policy, all_policies, Dic_t, para] = klspi_core(domain, algorithm, maxiterations, epsilon, samples, basis, discount, initial_policy, para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<8
    initialize_policy = [domain '_initialize_policy'];
    policy = feval(initialize_policy, 0.0, discount, basis);
    initial_policy = policy;
else
    policy = initial_policy;
    policy.time = 0;
end

if isempty(samples)
    %disp('Warning: Empty sample set');
    return
end
  
%
iteration = 0;
distance = 1000;

all_policies{1} = initial_policy;
all_policies{1}.time = 0;

%%%%spacifacion   
if (algorithm == 5)
    Dic = 0;
    [Dic_t,Dic_dim]=ald_analysis(samples,initial_policy,Dic, para);  %sparcifacion           
end
sampleNumber=length(samples);

while ( (iteration < maxiterations) & (distance > epsilon))
    
    i_start = tic;
    
    iteration = iteration + 1;
    %disp('*********************************************************');
    %disp( ['KLSPI iteration : ', num2str(iteration)] );
    Alpha=zeros(Dic_dim,1);
    k_hat=zeros(Dic_dim, 1);
    k_hat_next=zeros(Dic_dim, 1);
    b=zeros(Dic_dim,1);
    A=zeros(Dic_dim, Dic_dim);

    time = 0;

    for i=1:sampleNumber
        tic;
        k_hat=feval(policy.basis, samples(i).state, samples(i).action, Dic_t, para(1));
        if samples(i).absorb
            gamma_t=0;
            A=A+k_hat*k_hat';
        else
            gamma_t=policy.discount;

            nextaction=k_policy_function(policy, samples(i).nextstate, Dic_t, para(1));

            k_hat_next=feval(policy.basis, samples(i).nextstate, nextaction, Dic_t, para(1));
            A=A+k_hat*(k_hat'-gamma_t*k_hat_next');
        end
        b=b+samples(i).reward*k_hat;
        time = time + toc;
    end
    
    rankA = rank(A);
    k = size(A,1);
    %disp(['Rank of matrix A : ' num2str(rankA)]);
    if rankA==k
        %disp('A is a full rank matrix!!!');
        w = A\b;
    else
        %disp(['WARNING: A is lower rank!!! Should be ' num2str(k)]);
        w = pinv(A)*b;
    end
    policy.weights=w;
    
    all_policies{iteration+1}=policy;
    
    l1 = length(policy.weights);
    l2 = length(all_policies{iteration}.weights);
    
    if (l1 == l2)
      difference = policy.weights - all_policies{iteration}.weights;
      LMAXnorm = norm(difference,inf);
      L2norm = norm(difference);
    else
      LMAXnorm = abs(norm(policy.weights,inf) - norm(all_policies{iteration}.weights,inf));
      L2norm = abs(norm(policy.weights) - norm(all_policies{iteration}.weights));
    end
    
    distance = L2norm;
    %%% Print some information 
    %disp( ['Norms -> Lmax : ', num2str(LMAXnorm),'   L2 : ',            num2str(L2norm)] );

    %%% Store the current policy
    policy.time = policy.time + toc(i_start);
    all_policies{iteration+1} = policy;
    
    Dic_old = 0; 
    %%% Depending on the domain, print additional info if needed
    %feval([domain '_print_info'], all_policies, 1, Dic_t, Dic_old, para);
end

%Display some info
%disp('*********************************************************');
if (distance > epsilon)
    %disp(['KLSPI finished in ' num2str(iteration) iterations WITHOUT CONVERGENCE to a fixed point']);
else
    %disp(['KLSPI converged in ' num2str(iteration) ' iterations']);
end
%disp('********************************************************* ');  
return
