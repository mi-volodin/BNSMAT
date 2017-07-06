function  listDeletionFathomRule( obj )
%LISTDELETIONRULE Applies list-deletion fathoming rule
%   There are several of them
%   1. If Lpi has no open nodes (in L) and intersection of Lpi with any Lpj
%   in the same Lp is an empty set then
%       1.1 Fathom all k in Lpi (delete from Lpi and L_in)
%       1.2 Delete Lpi
%   2. If Lpi has no open nodes and intersection with some Lpj in Lp is an
%   empty set then just delete Lpi
%   3. If after all number of sublists in Lp is zero - delete* partition.
%   * - deletion of partition is not performed here

% newNodesInds = obj.nodes.numel() + (1:obj.iterInfo.nnew);
k_in_L = obj.L.keys();
k_to_fathom = [];
    if obj.debugLevel >= 3 
       fprintf('--> listDeletionRule\n'); 
    end
for i = 1:obj.partitions.numel()
    
    Lp = obj.partitions.dict(i).Lp;
    nLp = numel(Lp);
    s_to_fathom = false(nLp);
    if nLp == 0
        continue;
    end
    intIsEmpty = zeros(nLp); %ones because with 1x1 cell intersection is Empty
    hasNoOpenNodes = zeros(nLp,1);
    
    if nLp > 1
        for s = 1:nLp
            for sp = s+1:nLp
                intIsEmpty(s, sp) = isempty(intersect(Lp{s}, Lp{sp}));
            end
            hasNoOpenNodes(s) = isempty(intersect(Lp{s}, k_in_L));
        end
        intIsEmpty = intIsEmpty + intIsEmpty';
    else
       intIsEmpty = 1;
       hasNoOpenNodes = isempty(intersect(Lp{1}, k_in_L));
    end
    %has no open nodes
    for s = 1:nLp
       %% 1,2
       if hasNoOpenNodes(s)
           if all(intIsEmpty(s,:))
               % 1
               k_to_fathom = union(k_to_fathom, Lp{s});
%                s_to_fathom(s) = true(); %done by fathoming nodes
           elseif ~all(intIsEmpty(s, :) == 0)
               % 2
               s_to_fathom(s) = true();
           end
       end
    end
    if obj.debugLevel >= 3 
       fprintf('Partition %d\n Lp: { s: list}\n ', i);
       line = 1:numel(Lp);
       for c = line
           fprintf('%d:\t%s\n', c, num2str(Lp{c}));
       end
       fprintf('}\n Nodes fathomed (fully): %s\n Sublists manually deleted: %s\n', ...
           num2str(k_to_fathom), num2str(line(s_to_fathom)));
    end
    obj.fathomNodes(k_to_fathom);
    obj.partitions.dict(i).Lp(s_to_fathom) = []; 
end
    if obj.debugLevel >= 3 
       fprintf('<--\n'); 
    end

end

