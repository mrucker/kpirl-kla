function [samples, problem] = all_RAND(problem)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simulator = [problem.domain '_simulator'];
simulatenumber = problem.simulate_step_number;
all_samples = [];
i = 0;
while(i<problem.max_episode_number)
    sample = feval(simulator);
    samples = [];
    for j=1:problem.max_step_number
        action = ceil(rand*problem.action_number);
        sample = feval(simulator, sample.nextstate, action, simulatenumber);
        samples = [samples sample];
        if(sample.absorb)
            break;
        end
    end
    if(j < problem.max_step_number)
        i = i+1;
        all_samples = [all_samples samples];
    end
    if(problem.display)
        time = get_time();
        disp(['Episode : ' num2str(i) '    Steps : ' num2str(j)  '         Time : ' time]);
    end
end


samples = all_samples;
problem.samples_number = length(samples);
if(problem.display)
    disp(['Samples collected : ' num2str(problem.samples_number)]);
end
% save 'C:\Documents and Settings\liyan\My Documents\MATLAB\Rlearn\01samples\all_RAND.mat' samples problem;

return
