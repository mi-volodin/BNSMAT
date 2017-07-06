function appendNodeToL( obj, ks)
%APPENDNODETOL Appends node k to list L
%   
% kposs = obj.nodes.keytopos(ks);
for i = 1:numel(ks)
% memory consumption could be reduced. List used in selection procedures in step 2.
    str = struct('k', ks(i));%, 'l', [], 'f_ILB', [], 'f_IUB', [], ...
        %'F_LB', [], 'x_LB', []);
    
    
%     kpos = kposs(i);
%     str.f_ILB = obj.nodes.dict(kpos).f_ILB;
%     str.f_IUB = obj.nodes.dict(kpos).f_IUB;
%     str.F_LB = obj.nodes.dict(kpos).F_LB;
%     str.x_LB = obj.nodes.dict(kpos).x_LB;
%     str.l = obj.nodes.dict(kpos).l;
    
    obj.L.add(str);
end

