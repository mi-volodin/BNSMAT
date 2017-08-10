function step7_OuterUpperBound( obj )
%STEP7_OUTERUPPERBOUND Summary of this function goes here
%   1. Check if there are new open nodes
%   2. If no - go to step2
%   3. If yes for each node make
%       3.1 Fix x on x_LB for 
%       3.2 Find Lp and solve RISP for each node in Lp with fixed x in
%       domain of nodes in Lp
%       3.3 Find min w(x) and choose i
%       3.4 For i solve RIUB and get F_UB, x_UB, y_UB
%       3.5 If F_UB < best_UB -> update best UB
%       3.6 Scan all nodes in L and move nodes with F_LB > new_UB - eps_F
%       to L_in. 
%           3.6.1 If there were any - apply list deletion rule
%           3.6.2 If second new node were outer Fathomed, exit
%   4. Increase the node counter by nnew and go to step 2
    newOpenNodes = obj.iterInfo.newNodes(obj.iterInfo.newNodes <= obj.nodeCtr + 2);
    nodesToProcess = intersect(newOpenNodes, obj.L.keys());
    %% 2
    if isempty(nodesToProcess)
        % apply list deletion rule
        % obj.listDeletionFathomRule();
        if obj.debugLevel >= 1
            fprintf('---------------------------\n');
            fprintf('Step 7:\nNo nodes to process, goto Step 2');
        end
        return;
    end
    %% 3    
    kposs = obj.nodes.keytopos(nodesToProcess);
    allk  = obj.nodes.keys();
    pposs = obj.getPartitionOfNodes(nodesToProcess);
    

    for i = 1:numel(nodesToProcess)
        %3.6.2
        k = nodesToProcess(i);
        if obj.nodes.dict(kposs(i)).is_of
            %this should never occure
            error('Logic error, node were deleted on step 7');
        end
        %% 3.1
        x_LB = obj.nodes.dict(kposs(i)).x_LB;
        
        %% 3.2
        Lp = obj.partitions.dict(pposs(i)).Lp;
        for s = 1:numel(Lp)
            if all(Lp{s} ~= k)
                Lp{s} = [];
            end
        end
        Lpf = unique([Lp{:}]);
        % filter only suitable nodes
        ISPnodes = zeros(1, numel(Lpf));
        ptr = 2;
        ISPnodes(1) = k;
        Lpf(Lpf == k) = [];
        for n = Lpf
            if XpointIsInDomain(x_LB, obj.nodes.dict(allk == n).domain)
                ISPnodes(ptr) = n;
                ptr = ptr + 1;
            end
        end
        ISPnodes(ISPnodes == 0) = [];
        RISPv = inf(numel(ISPnodes), 2);
        for j = 1:numel(ISPnodes)
            RISPv(j, 2) = j;
            % TODO w(x) values should be reused!
            [~, RISPv(j, 1)] = obj.Problem.solveISP(x_LB, obj.nodes.dict(allk == ISPnodes(j)).domain);
       end

       %% 3.3
       minISP = min(RISPv(:,1));
       w_minISP = RISPv(RISPv(:,1) == minISP, 1);
       k_minISP = RISPv(RISPv(:,1) == minISP, 2);
       
       %% 3.4
       [feas, F_UB, y_UB] = obj.Problem.solveUB(w_minISP, x_LB, ...
           obj.nodes.dict(allk == k_minISP).domain);
       
       if feas && F_UB < obj.bestUB.F
           obj.setBestUB(F_UB, x_LB, y_UB);
       end
       
          
    end
     %% 3.6
    nodesInL = obj.L.keys();
    OFCandidates = nodesInL;
    for l = nodesInL
        if ~(obj.nodes.dict(allk == l).F_LB > F_UB - obj.eps_F)
            % ADD CLOSED NODES CHECK HERE
            %outerFathom node list
            OFCandidates(OFCandidates == l) = [];
        end 
    end
    obj.outerFathomNodes(OFCandidates);
    if ~isempty(OFCandidates)
        obj.listDeletionFathomRule();
    end 
    
   
    
    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 7:\n Processed nodes:\n');
        fprintf('\tL:\t{k,\tl,\tf_ILB,\tf_IUB,\tF_LB}\n');
        for k = nodesToProcess
            nstr = obj.nodes.dict(k);
            fprintf('\t\t %d,\t%d,\t\t%d,\t\t%d,\t%d\n', k, nstr.l, nstr.f_ILB, nstr.f_IUB, nstr.F_LB);
        end
        fprintf('Best UB (F):\t %d\n', obj.bestUB.F);
        if ~isempty(OFCandidates)
            fprintf('Outer fathomed nodes: %s\n', mat2str(OFCandidates));
        end
%         fprintf('Node counter: %d -> %d\n', obj.nodeCtr, obj.nodeCtr);
    end
end

function yes = XpointIsInDomain(x, domain)
    domain(numel(x)+1:end, :) = [];
    yes = (domain(:,1) <= x) & (domain(:,2) >= x);
end
    
    
    

