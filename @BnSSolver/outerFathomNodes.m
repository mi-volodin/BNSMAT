function outerFathomNodes( obj, ks )
%OUTERFATHOMNODES Moves from L to L_in and tweaks the node properties
    if isempty(ks)
        return;
    end
        
    kposs = obj.nodes.keytopos(ks);
    for i = 1:numel(ks)
        kpos = kposs(i);
        obj.nodes.dict(kpos).is_of = 1;
        obj.nodes.dict(kpos).F_LB = [];
        obj.nodes.dict(kpos).x_LB = [];
    end
    
    obj.L.removeByKey(ks);
    obj.appendNodeToLin(ks);


end

