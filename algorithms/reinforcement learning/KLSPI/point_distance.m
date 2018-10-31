function [r, ind, s] = point_distance(state, Dic, stateweight)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global D 

for j=1:length(state)
    if state(j)>D
        state(j)=D;
    end
end

[dim, nfea] = size(Dic);
s = zeros(dim, 1);
for i=1:dim
    for j=1:nfea
        s(i) = s(i) + (state(j)-Dic(i,j))^2/stateweight(j)^2;
    end
    %s(i) = sqrt(s(i));
end
[r, ind] = min(s);

return
