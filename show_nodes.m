L_set = [slv.L.dict(:).k];
L_in_set = [slv.L_in.dict(:).k];
for i = 1:slv.nodes.numel()
    node = slv.nodes.dict(i);
    in_L = ismember(node.k, L_set);
    in_Lin = ismember(node.k, L_in_set);
    fprintf('%d:\t %d-%d-%d\tILB %d\tIUB %d\tLB %d\tx [%d %d]\ty [%d %d]\n', ...
        node.k, node.is_of, ...
        in_L, in_Lin, node.f_ILB, node.f_IUB, node.F_LB, node.domain(1), ...
        node.domain(3), node.domain(2), node.domain(4));
end