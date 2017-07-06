function appendNodeToLin( obj, ks)
%APPENDNODETOL Appends node k to list L
%   
% kposs = obj.nodes.keytopos(ks);
for i = 1:numel(ks)
% memory consumption could be reduced. List used in selection procedures in step 2.
    str = struct('k', ks(i));%, 'l', [], 'f_ILB', [], 'f_IUB', []);
    
%     
%     kpos = kposs(i);
%     str.f_ILB = obj.nodes.dict(kpos).f_ILB;
%     str.f_IUB = obj.nodes.dict(kpos).f_IUB;
%     str.l = obj.nodes.dict(kpos).l;
    
    obj.L_in.add(str);
end

