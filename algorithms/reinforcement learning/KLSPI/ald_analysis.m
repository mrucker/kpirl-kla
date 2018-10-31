function [Dic_t, Dic_dim] = ald_analysis(samples, policy, Dic, para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


mu           = para(3);                           
sampleNumber = length(samples);   % number of data samples  
Dic_dim      =1;

Dic_t= feval(policy.basis, samples(1).state, samples(1).action)';

ktt=feval(policy.basis, samples(1).state, samples(1).action, Dic_t, para(1)); 

K_Inv=zeros(Dic_dim, Dic_dim);
K_Inv(1,1)=1.0/ktt;

K_t=zeros(1,1);

if size(Dic, 1)==1
    policy.explore=1;  % purely random policy
end

for i=1:sampleNumber

        state=samples(i).state;
        action=samples(i).action;              

        k_t=feval(policy.basis, state, action, Dic_t, para(1));

        a_t=K_Inv*k_t;

        current_feature=feval(policy.basis, state, action)';
        
        ktt=feval(policy.basis, state, action, current_feature, para(1));
        delta=ktt-transpose(k_t)*a_t;
        
        if  abs(delta)<mu
            
        else  
            
            Dic_dim=Dic_dim+1;            
            Dic_t  =vertcat(Dic_t, current_feature);            
            
            %% K_Inv(t)=[ K_Inv(t-1)+a_t*a_t'/delta,  -a_t/delta ]
            %%          [   -a_t'/delta ,                 1/delta]
            K_Inv=K_Inv+a_t*transpose(a_t)/delta;
            
            temp=-a_t/delta;
            
            K_Inv=UpdateMatrix( K_Inv, temp, temp, 1/delta, Dic_dim-1, Dic_dim-1, Dic_dim, Dic_dim);
            %% Update K_t= [K_(t-1),  k_t; k_t',  1]            
            K_t=UpdateMatrix( K_t, k_t, k_t, 1, Dic_dim-1,Dic_dim-1, Dic_dim, Dic_dim);
        end  %% End of if-else 
end  %% End of for 

