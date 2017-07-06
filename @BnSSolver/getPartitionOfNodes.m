function [ ppos, p ] = getPartitionOfNodes( obj, ks )
%GETPARTITIONOFNODE Summary of this function goes here
%   Detailed explanation goes here
    p = zeros(size(ks));
    ppos = p;
    positions = 1:obj.partitions.numel();
    for i = positions
       [mask, idx] = ismember([obj.partitions.dict(i).Lp{:}], ks);
       if any(mask)
           ppos(idx(mask)) = i;
           p(idx(mask)) = obj.partitions.dict(i).p;
       end
   end

end

