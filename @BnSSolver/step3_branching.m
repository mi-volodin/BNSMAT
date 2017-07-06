function step3_branching(obj)
%STEP3_BRANCHING performs branching
%   Branching 
%   NOTE: Branching is made using exact bisection as it's done by authors
%   1.1 Branch on x or y variables at node k to create
%   two new nodes, i.e., nnode+1 and nnode+2, initialize node properties.
%   1.2 Set n_new := 2.
%   2.1 If a node k_in is selected, branch at k_in to create two
%   new (outer-fathomed) nodes, i.e., nnode+3 and nnode+4 and initialize
%   node properties.
%	2.2 Set nnew := 4.
%   
%   List management
%   3.1 For new nodes i in (nnode+1 ... nnode+nnew) find corresponding 
%   subdomain Xi_pi such that i in Lp_i.
%   3.2 Set/update f_UB_pi for Xi_pi
%   3.3 Apply inner-value-dominance fathoming rule (cf., Definition 3 of
%   the Paper)

% 1
    k = obj.iterInfo.k;
    p = obj.iterInfo.p_of_k;
    obj.iterInfo.nnew = 0;
    [k1, k2] = obj.branchInNode(k, p);
    ks = [k1 , k2];
    % 2
    k_in = obj.iterInfo.k_in;
    if ~isempty(k_in)
        [k3, k4] = obj.branchInNode(k_in, p);
        ks = [ks k3 k4];
    end
    obj.iterInfo.newNodes = ks;
    % 3

    %TODO CYCLE COULD BE FLATTENED
    %3.1 3.2
    [ppos] = obj.getPartitionOfNodes(ks);
    ppos = unique(ppos);
    for i = 1:numel(ppos)
        obj.updatePartitionBestIUB(ppos(i));
    end
    %3.3
    obj.iterInfo.step3FathomedNodes = obj.innerFathomRule(ks);

    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 3. Branching\n');
        fprintf('\tNew open nodes: %s\n', mat2str([k1 k2]));
        if numel(ks) > 2
            fprintf('\tNew inner-open nodes: %s\n', mat2str([k3 k4]));
        end
        fprintf('\tNodes fathomed: %s\n', num2str(obj.iterInfo.step3FathomedNodes));
    end
end

