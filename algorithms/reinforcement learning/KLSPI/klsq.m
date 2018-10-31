function [Dic_t, Dic_dim] = ald_analysis(samples, policy, Dic, para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%初始化变量
sparcification = para(2);  %Sparcification flag, para(1)= RBF width
mu = para(3);                           
sampleNumber = length(samples);   % number of data samples  
sigma=0;

%初始化核词典数据和特征数据
mytime = cputime;
Dic_dim=1;
feature_dim=size(samples(1).state,2)*policy.actions;
Dic_t=zeros(Dic_dim, feature_dim);
current_feature=zeros(1,feature_dim); 
index=(samples(1).action-1)*size(samples(1).state,2);
for j=1:size(samples(1).state,2)
    Dic_t(1,index+j)=samples(1).state(j);    
end	
ktt=zeros(1,1);
ktt=feval(policy.basis, samples(1).state, samples(1).action, Dic_t, para(1)); 
K_Inv=zeros(Dic_dim, Dic_dim);
K_Inv(1,1)=1.0/ktt;
a_t=zeros(Dic_dim,1);
a_t(1,1)=1;
k_t=zeros(Dic_dim,1);
K_t=zeros(1,1);		 


if size(Dic, 1)==1
    policy.explore=1;  % purely random policy
end
   
% 开始进行核矩阵稀疏化计算
for i=1:sampleNumber
    %判断是否为终端状态
    if  samples(i).absorb
        %当前为吸收状态, h(t,t)=1, h(t,t+1)=0
        gamma_t=0;
    else
        %% 中间状态,h(t,t)=1, h(t,t+1)=-gamma
        gamma_t=policy.discount;
 
       state=samples(i).state;
       action=samples(i).action;
      
        %计算矩阵的近似线性相关系数 compute ALD value delta and store reward valuedisp([num2str(i) ':   ']);
        k_t=zeros(Dic_dim,1);
		k_t=feval(policy.basis, state, action, Dic_t, para(1));
        a_t=zeros(Dic_dim,1);
        a_t=K_Inv*k_t;
        current_feature=zeros(1, feature_dim);
        index=(action-1)*size(state,2);
        for j=1:size(state,2)
            current_feature(1,index+j)=state(j);
        end
        ktt=feval(policy.basis, state, action,current_feature, para(1));
        delta=ktt-transpose(k_t)*a_t;
        %判断是否线性相关
        if  abs(delta)<mu
            %如果线性相关，则核矩阵的维数不变
        else  
            %线性无关，增加维数			
            Dic_dim=Dic_dim+1;
            temp=zeros(Dic_dim, feature_dim);
            temp(1:Dic_dim-1,:)=Dic_t;
            index=(action-1)*size(state,2);
            for j=1:size(state,2)
                temp(Dic_dim,index+j)=state(j);
            end
            clear Dic_t;
            Dic_t=zeros(Dic_dim, feature_dim);
            Dic_t=temp;
            %% K_Inv(t)=[ K_Inv(t-1)+a_t*a_t'/delta,  -a_t/delta ]
            %%          [   -a_t'/delta ,                 1/delta]
            K_Inv=K_Inv+a_t*transpose(a_t)/delta;
            temp=zeros(Dic_dim-1,1);
            temp=-a_t/delta;
            Mat_new=zeros(Dic_dim, Dic_dim);
            Mat_new=UpdateMatrix( K_Inv, temp, temp, 1/delta, Dic_dim-1, Dic_dim-1, Dic_dim, Dic_dim);
            K_Inv=zeros(Dic_dim, Dic_dim);
            K_Inv=Mat_new;		
            %% Update K_t= [K_(t-1),  k_t; k_t',  1]
            Mat_new=zeros( Dic_dim, Dic_dim);
            Mat_new=UpdateMatrix( K_t, k_t, k_t, 1, Dic_dim-1,Dic_dim-1, Dic_dim, Dic_dim);
            K_t=zeros(Dic_dim, Dic_dim);
            K_t=Mat_new;
        end  %% End of if-else 
end  %% End of for 


