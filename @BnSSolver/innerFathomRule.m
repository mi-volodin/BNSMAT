function fathomed_ks = innerFathomRule( obj, ks )
%INNERFATHOMRULE Apply inner-fathoming rule for node k
%   1. Find p: k in Lp.
%   2. Check f_RILB
%       f_RILB = +Inf 
%       or
%       f_RILB > f_UB_p
%   3. If true - fathom
ppos = obj.getPartitionOfNodes(ks);
kpos = obj.nodes.keytopos(ks);
% ks is sorted, node dict is also sorted, so positions preserved
f_ILBv = [obj.nodes.dict(kpos).f_ILB];
f_UB = [obj.partitions.dict(ppos).f_IUB];

rule = isinf(f_ILBv) | (f_ILBv > f_UB + obj.eps_F);
fathomed_ks = ks(rule);

if obj.debugLevel >= 3
    fprintf('-->innerFathomRule:\n f_ILB == Inf: %s\n f_ILB > f_UB: %s\nTOTAL: %s\n<--\n', ...
                num2str(ks(isinf(f_ILBv))), ...
                num2str(ks(f_ILBv > f_UB)), ...
                num2str(fathomed_ks));
end

%% FATHOM
obj.fathomNodes(fathomed_ks);

end

