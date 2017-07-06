function  [go_to_step2] = step5_InnerUpperBound( obj )
%STEP5_INNERUPPERBOUND Inner upper bound computation step
%   Quite similar to step4
%   1. Check if new nodes still exists. If all of them not - apply list
%   deletion rule and go to step 2.
%   2. For 'new' nodes in L union L_in solve RIUB to get f_IUB.
%   3. Update f_IUB on L and L_in (I preserve the characteristics in nodes)
%   4. Update f_IUB for corresponding partitions
%   5. Apply the inner-value dominance rule
%   6. If necessary(?) apply list-deletion rule.
go_to_step2 = 0;
    %% 1
    newNodesToProcess = intersect(obj.iterInfo.newNodes, union(obj.L.keys(), obj.L_in.keys()));
    newNodesToProcess = newNodesToProcess(:)'; %just to be sure it's a row
    if isempty(newNodesToProcess)
        % apply list deletion rule
        obj.listDeletionFathomRule();
        go_to_step2 = 1;
        return;
    end
    
    %% 2 
    %feas = zeros(size(newNodesToProcess));
    kposs = obj.nodes.keytopos(newNodesToProcess);
    pposs = obj.getPartitionOfNodes(newNodesToProcess);

    %OPT: if splitted by sync pieces, parfor could be used.
    for i = 1:numel(newNodesToProcess);
        % make a copy of the source problem with corresponding domain
        %solve RILB
        [~, obj.nodes.dict(kposs(i)).f_IUB] = obj.Problem.solveRIUB(obj.nodes.dict(kposs(i)).domain);
        
        %here must be a list update step - I saved characteristics in
        %nodes, so no need to
    end
    
    for p = unique(pposs)
        obj.updatePartitionBestIUB(p);
    end
    
    fathomed_nodes = obj.innerFathomRule(newNodesToProcess);

    if ~isempty(fathomed_nodes)
        %delete node from Lpi
        %obj.deleteNodesFromLp(newNodesToProcess(~mask1));
        obj.listDeletionFathomRule();
    end
    
    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 5 Inner Upper Bound:\n');
        if obj.debugLevel >= 2
            fprintf('Computed: ');
            comp = [obj.nodes.dict(kposs).f_IUB];
            for i = 1:numel(comp)
                fprintf(' f_IUB_(%d)=%d, ', newNodesToProcess(i), comp(i));
            end
            fprintf('\n');
        end
        fprintf('\tL:\t{k,\tl,\tf_ILB,\tf_IUB,\tF_LB}\n');
        for k = intersect(newNodesToProcess, obj.L.keys())
            if isempty(k)
                break;
            end
            nstr = obj.nodes.dict(k);
            fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d,\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB, nstr.F_LB);
        end
        fprintf('\tL:\t{k,\tl,\tf_ILB,\tf_IUB}\n');
        for k = intersect(newNodesToProcess, obj.L_in.keys())
            if isempty(k)
                break;
            end
            nstr = obj.nodes.dict(k);
            fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB);
        end
        if ~isempty(fathomed_nodes)
            fprintf('Inner fathomed nodes: %s\n', mat2str(fathomed_nodes));
        end
    end

end

