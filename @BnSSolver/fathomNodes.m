function  fathomNodes( obj, nodes )
%FATHOMNODE Fathoming deletes node from L and L_in, as well from Lps
%   Detailed explanation goes here
if isempty(nodes)
    return;
end
    obj.L.removeByKey(nodes);
    obj.L_in.removeByKey(nodes);
    obj.deleteNodesFromLp(nodes);
end

