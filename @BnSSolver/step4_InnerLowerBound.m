function [go_to_step2] = step4_InnerLowerBound( obj )
%STEP4_INNERLOWERBOUND Inner Lower bound computation step
%   1. Check if new nodes still exists. If all of them not - apply list
%   deletion rule and go to step 2.
%   2. For 'new' nodes solve RILB to get f_ILB.
%   3. If feasible and f_ILB < f_UB_p
%       3.1 If k is open - add to L with updated ILB
%       3.2 If k is outer-fathomed - add to L_in with update ILB
%   4. If infeasible - remove i from Lp. Apply list deletion rule
    go_to_step2 = 0;
    %% 1
    newNodes = obj.iterInfo.newNodes;
    if isempty(setdiff(newNodes, obj.iterInfo.step3FathomedNodes))
        % apply list deletion rule
        obj.listDeletionFathomRule();
        go_to_step2 = 1;
        return;
    end

    %% 2
    %obj.iterInfo.newNodesProblems = cell(numel(obj.iterInfo.newNodes),1);
    feas = zeros(size(newNodes));
    kposs = obj.nodes.keytopos(newNodes);
    pposs = obj.getPartitionOfNodes(newNodes);

    %OPT: if splitted by sync pieces, parfor could be used.
    for i = 1:numel(newNodes);
        % make a copy of the source problem with corresponding domain
        kdom = obj.nodes.dict(kposs(i)).domain;
%         obj.iterInfo.newNodesProblems{i} = obj.Problem.copy(kdom);

        %solve RILB
        [feas(i), obj.nodes.dict(kposs(i)).f_ILB] = obj.Problem.solveRILB(kdom);
    end
    
    mask1 = feas & ([obj.partitions.dict(pposs).f_IUB] + obj.Problem.eps_f > [obj.nodes.dict(kposs).f_ILB]);
    
    Lmask = mask1 & ~[obj.nodes.dict(kposs).is_of];
    Linmask = mask1 & [obj.nodes.dict(kposs).is_of];
    obj.appendNodeToL(newNodes(Lmask));
    obj.appendNodeToLin(newNodes(Linmask));

    if any(~mask1)
        %delete node from Lpi
        obj.deleteNodesFromLp(newNodes(~mask1));
        obj.listDeletionFathomRule();
    end

    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 4. Inner Lower Bound\n');
        if obj.debugLevel >= 2
            fprintf('Computed: ');
            comp = [obj.nodes.dict(kposs).f_ILB];
            for i = 1:numel(comp)
                fprintf(' f_ILB_(%d)=%d, ', newNodes(i), comp(i));
            end
            fprintf('\n');
        end
        fprintf('\tL:\t{k,\tl,\tf_ILB,\tf_IUB,\tF_LB}\n');
        for k = newNodes(Lmask)
            nstr = obj.nodes.dict(k);
            fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d,\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB, nstr.F_LB);
        end
        fprintf('\tL:\t{k,\tl,\tf_ILB,\tf_IUB}\n');
        for k = newNodes(Linmask)
            nstr = obj.nodes.dict(k);
            fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB);
        end
        if ~isempty(newNodes(~mask1))
            fprintf('Deleted nodes: %s\n', mat2str(newNodes(~mask1)'));
        end
    end
end
