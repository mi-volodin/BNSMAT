function  addRootNode( obj, k, l, domain, f_ILB, f_IUB, F_LB, x_LB )
%ADDNODE Adds new node to solver tree
%   Detailed explanation goes here
    obj.nodes.add(struct('k', k, 'l', l, 'domain', domain, 'f_ILB', f_ILB, ...
        'f_IUB', f_IUB, 'F_LB', F_LB, 'x_LB', x_LB, 'is_of', 0));
    obj.nodeCtr = obj.nodeCtr + 1;
end
