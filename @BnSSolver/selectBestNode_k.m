function [bestk, ppos] = selectBestNode_k( obj )
%SELECTBESTNODEK Select node k that will be used for branching
%   1. Select node in L with lowest F_LB
%   2. Select Lp that includes this node (Lp intersect Lq is empty for p <>
%   q), which actually performs the selection of Xi_p (partition p).
%   3. Forget about selected in p.1 node, now choose k in Lp intersection 
%   with L with lowest level, and lowest LB (first level, next F_LB).

%% p.1

    ks = sort(obj.L.keys());
    kmask = ismember(obj.nodes.keys(), ks);
    LB = [obj.nodes.dict(kmask).F_LB];
    lowestLB = min(LB);
    k = min(ks(LB == lowestLB));

    %   p.1 cycle version

%     k = obj.L(1).k;
%     lowestLB = obj.L(1).F_LB;
%     for i = 2:obj.L.numel()
%         if obj.L(i).F_LB < lowestLB
%             lowestLB = obj.L(i).F_LB;
%             k = obj.L(i).k;
%         end
%     end
    
%% p.2
 
   [ppos, p] = obj.getPartitionOfNodes(k);
   Lp = obj.partitions.dict(ppos).Lp;
%    p = [];
%    Lp = {};
%    for i = 1:obj.partitions.numel()
%        if any([obj.partitions(i).Lp{:}] == k)
%            p = obj.partitions(i).p;
%            Lp = obj.partitions(i).Lp;
%        end
%    end
   if isempty(p) || isempty(Lp)
       error('Step2: Logic error, node is not connected to any Lp');
   end
   
%% p.3
   % find intersection
   LcapLp = intersect(obj.L.keys(), [Lp{:}]);
   nodes = [  obj.nodes.dict(kmask).k; [obj.nodes.dict(kmask).l]; LB ]';
   
   %filter by intersection
   nodes = nodes(ismember(nodes(:,1), LcapLp), :);
   %select lowest level
   minl = min(nodes(:, 2));
   nodes = nodes(nodes(:,2) == minl, :);
   if size(nodes,1) == 1
       bestk = nodes(1);
   else
       %filter by LB
       lowestLB = min(nodes(:,3));
       bestk = nodes(nodes(:,3) == lowestLB, 1);
       if numel(bestk) > 1
           bestk = min(bestk);
           if obj.debugLevel > 0
               fprintf('NOTE:\t two nodes were selected with same characteristics\n');
           end
       end
   end
end

