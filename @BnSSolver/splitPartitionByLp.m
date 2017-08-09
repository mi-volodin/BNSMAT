function splitPartitionByLp( obj, p, Lp1, Lp2 )
%SPLITPARTITIONSBYLP Creates new partition for Lp2 and replaces Lp by Lp1 in partition Xi_p
%   1. Replace Lp in p by Lp1 or Lp2 depending on where k_in is
%   2. Create copy partition (preserve f_UB), with Lp = Lp2/1 respectively
%   3. Increase p
    obj.partitions.dict(p).Lp = Lp1;
    newstr = obj.partitions.dict(p);
    newstr.Lp = Lp2;
    newstr.p = obj.partitions.numel() + 1;
    obj.partitions.add(newstr);
end

