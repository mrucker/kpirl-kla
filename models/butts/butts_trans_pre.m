function s2 = huge_trans_pre(s1, a, should_update_targets)

    %removed for speed
    %huge_states_assert(s1);

    if(nargin < 2)
        a = [];
    end

    if(nargin < 3)
        should_update_targets = true;
    end
    
    if ~isempty(a)
        s2 = huge_trans_post(s1, a, should_update_targets);
    else
        s2 = s1;    
    end

    width  = s1(9);
    height = s1(10);
    radius = s1(11);

    s2 = create_new_targets(s2, width, height, radius);
end



function x2 = create_new_targets(x1, width, height, radius)
    
    %the actual web app uses an exponential interarrival time to have continous arrivals
    %for easier calculation in matlab I'm using repeated bernoulli trials since n is large and p is small
    %p = @(k,t) exp(-t/200) * ((t/200)^k)/factorial(k); p(2,33) -- https://planetcalc.com/7044/

    n = 33;     %could appear at any ms tick
    p = (1/200);%this is the poisson lambda???? Yes, I think so. That is, 1/200'th of a target arrives each milisecond
    
    targets_to_create = binornd(n,p);
        
    x2 = x1;

    if targets_to_create == 0
        return;
    end
    
    new_targets_rands = rand(2,targets_to_create);
    new_targets_scale = diag([(width  - radius*2), (height - radius*2)]);
    
    new_targets_point = new_targets_scale * new_targets_rands;
    new_targets_age   = 10 * ones(1, targets_to_create); %we make age 10 because 10+(33*30) = 1000
            
    if(size(x2,2) >  1)
        x3 = vertcat(x2, repmat(reshape([new_targets_point;new_targets_age],[],1), 1, size(x2,2)));
    else 
        x3 = vertcat(x2, reshape([new_targets_point;new_targets_age],[],1));
    end
    x2 = x3;
end