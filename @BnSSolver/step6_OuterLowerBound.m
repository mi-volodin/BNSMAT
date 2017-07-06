function [ go_to_step2 ] = step6_OuterLowerBound( obj )
%STEP6_OUTERLOWERBOUND Compute Outer lower bound for open nodes (L)
%   Quite similar to step4
%   1. Check if new open nodes still exists in L. If all of them not - apply list
%   deletion rule and go to step 2.
%   2. For 'new' nodes in L solve LB to get F_LB and x_LB.
%   3. If feasible and F_LB < F_UB + eps_F 
%       3.1 Update F_LB and x_LB in node
%   4. Else - outer-fathom node (add to L_in) and apply list deletion rule

go_to_step2 = 0;
    %% 1
    newOpenNodes = obj.iterInfo.newNodes(obj.iterInfo.newNodes <= obj.nodeCtr + 2);
    nodesToProcess = intersect(newOpenNodes, obj.L.keys());
    if isempty(nodesToProcess)
        % apply list deletion rule
        obj.listDeletionFathomRule();
        go_to_step2 = 1;
        if obj.debugLevel >= 1
            fprintf('---------------------------\n');
            fprintf('Step 6:\nNo nodes to process, goto Step 2');
        end
        return;
    end
    
    %% 2 
    feas = zeros(size(nodesToProcess));
    kposs = obj.nodes.keytopos(nodesToProcess);
    pposs = obj.getPartitionOfNodes(nodesToProcess);
    f_IUB_p = [obj.partitions.dict(pposs).f_IUB];
    

    %OPT: if splitted by sync pieces, parfor could be used.
    for i = 1:numel(nodesToProcess);
        % make a copy of the source problem with corresponding domain
        %solve RILB
        [feas(i), obj.nodes.dict(kposs(i)).F_LB, obj.nodes.dict(kposs(i)).x_LB] = ...
            obj.Problem.solveLB(obj.nodes.dict(kposs(i)).domain, ...
            f_IUB_p(i));
        
        %here must be a list update step - I saved characteristics in
        %nodes, so no need to
    end
    
    mask = feas & ([obj.nodes.dict(kposs).F_LB] >= (obj.bestUB.F - obj.eps_F));
    
    if any(mask)
        obj.outerFathomNodes(nodesToProcess(mask));
        obj.listDeletionFathomRule();
    end
    
    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 6:\n');
        fprintf('\tL:\t{k,\tl,\tf_ILB,\tf_IUB,\tF_LB}\n');
        for k = intersect(nodesToProcess, obj.L.keys())
            if isempty(k)
                break;
            end
            nstr = obj.nodes.dict(k);
            fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d,\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB, nstr.F_LB);
        end
        fprintf('Checking F_UB - eps = %.5d < F_LB?\n', obj.bestUB.F - obj.eps_F); 
        if ~isempty(nodesToProcess(mask))
            fprintf('Outer fathomed nodes: %s\n', mat2str(nodesToProcess(mask)));
            for k = intersect(nodesToProcess, obj.L_in.keys())
                if isempty(k)
                    break;
                end
                nstr = obj.nodes.dict(k);
                fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB);
            end
        else
            fprintf('No changes\n');
        end
    end

end

