function  splitCopyNode( obj, k, newk1, dom1, newk2, dom2 )
%SPLOTCOPYNODE Subprocess in branching: make copy of old node, change domain
%   1. Copy nodes at the end
%   2. Change domain
%   3. Insert to dict

    keys = obj.nodes.keys();
    str = obj.nodes.dict(keys == k);
    str.l = str.l + 1;

    str.k = newk1;
    str.domain = dom1;
    if any(str.x_LB > dom1(1:obj.xdim, 2) | str.x_LB < dom1(1:obj.xdim, 1))
        str.x_LB = [];
    end
    obj.nodes.add(str);
    
    str.k = newk2;
    str.domain = dom2;
    try 
        if any(str.x_LB > dom2(1:obj.xdim, 2) | str.x_LB < dom2(1:obj.xdim, 1))
            str.x_LB = [];
        end
        obj.nodes.add(str)
    catch err
        error('shit');
    end


end

