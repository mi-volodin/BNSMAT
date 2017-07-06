function terminate = step2_nodeSelection( obj )
%STEP2_NODESELECTION Performs Step 2: node selection 
%   Detailed description contained in the paper
%   1. If L is empty - terminate and report solution
%   2. If it's not iterCtr += 1
%       2.1 Select best candidate Lp and best node k in 
%           Lp intersection with L. Remove k from L
%       2.2 If Lp intersection with L is not empty -
%           select best candidate k_in from this intersection;
%           remove k_in from L_in;
%   3. Save results for further steps
terminate = 0;
%% p.1
    if obj.L.isempty()
        obj.terminate()
        terminate = 1;
        return;
    end
    
    obj.iterCtr = obj.iterCtr + 1;
%% p.2
%p.2.1
    [k, ppos] = obj.selectBestNode_k();
    obj.L.removeByKey(k);
    
%p.2.2
    Lin_cap_Lp = intersect(obj.L_in.keys(), [obj.partitions.dict(ppos).Lp{:}]);
    k_in = [];
    if ~isempty(Lin_cap_Lp)
        k_in = obj.selectBestNode_k_in(Lin_cap_Lp);
        obj.L_in.removeByKey(k_in);
    end

%p.3
    % TODO
    obj.iterInfo.k = k;
    obj.iterInfo.k_in = k_in;
    obj.iterInfo.p_of_k = ppos;
    
    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 2. Node selection:\n Iteration:%d\n',obj.iterCtr);
        fprintf('\tOpen node selected: %d\n', k);
        fprintf('\tInner-open node selected: %d\n', k_in);
    end

end

