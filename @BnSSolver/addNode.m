function  addNode( obj, k, l, domain )
%ADDNODE Adds new node to solver tree
%   Detailed explanation goes here
    obj.nodes.add(struct('k', k, 'l', l, 'domain', domain));
    obj.nodeCtr = obj.nodeCtr + 1;
end

