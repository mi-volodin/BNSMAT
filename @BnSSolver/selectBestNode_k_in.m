function [bestk] = selectBestNode_k_in( obj, Lin_cap_Lp )
%SELECTBESTNODEK Similar to k selection, but Lp is already defined, so...
%   1. Choose k_in in Lp intersection with L_in with lowest level, and lowest 
%   LB (first prioroty level, next F_LB).
   
%% p.1
   % find intersection
   kmask = ismember(obj.nodes.keys(), Lin_cap_Lp);
   nodes = [  [obj.nodes.dict(kmask).k]; [obj.nodes.dict(kmask).l] ]';
   
   %select lowest level
   minl = min(nodes(:, 2));
   nodes = nodes(nodes(:, 2) == minl, :);
   if size(nodes,1) == 1
       bestk = nodes(1);
   else
       bestk = nodes(1);
       warning('Warning: %d inner nodes presented, one selected', size(nodes,1));
   end
end

