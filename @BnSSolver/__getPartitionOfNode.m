function [ ppos, p ] = getPartitionOfNode( obj, ks )
%GETPARTITIONOFNODE Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:obj.partitions.numel()
       if any(ismember([obj.partitions.dict(i).Lp{:}], ks))
           p = obj.partitions.dict(i).p;
           ppos = i;
           return;
       end
   end

end

