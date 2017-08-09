function [k1, k2] = branchInNode(obj, k, p )
%BRANCHINNODE Performs branching
%   1. Get domain of node
%   1.1 Get restricted indices, calc allowed
%   1.2 Get integer indices
%   2. Calculate edge length
%   3. If there's any integers - pick up them first. Choose longest edge
%   4. Choose smallest variable ordinal number
%   5. Bisect
%   6. List management of partitions

    %% 1
    kpos = obj.nodes.keytopos(k);
    dom = obj.nodes.dict(kpos).domain;
    xdim = obj.xdim;
    ydim = obj.ydim;
    line = 1:(xdim + ydim);
    %lineyfirst = [ydim + (1:xdim) 1:ydim];

    %% pre2
    restrict = obj.branchRestrictVarInds;
    allowed = setdiff(line, restrict);
    integers = obj.intVarIndices;
    
    allowedInts = intersect(integers, allowed);
    allowedCont = setdiff(allowed, integers);
    
    %% 2
    edges = dom(:,2) - dom(:,1);
    
    %% 3,4
    searchSet = [];
    if ~isempty(allowedInts)
        searchSet = allowedInts;
    else
        searchSet = allowedCont;
    end
    
    eSubset = edges(searchSet);
    longestEdge = max(eSubset);
    branchVarInd = min(searchSet(eSubset == longestEdge));
    
    % check if the node cannot be branched
%     if ~(longestEdge > 0 + double(any(obj.intVarIndices == branchVarInd)))
%         return;
%     end
%     branchVarInd = min(line(edges == longestEdge));
    %first iteration branch on y
%     if obj.iterCtr == 1
%         longestEdge = max(edges(xdim + 1:end));
%         branchVarInd = min(line((edges == longestEdge)' & line > xdim));
%     end

    %% 5 Bisection
    midpoint = sum(dom(branchVarInd, :))/2;
    %tests
    if isinf(midpoint) || isnan(midpoint)
        error('Logic error: the domain could not be branched (inf: %d, NaN: %d)', isinf(midpoint), isnan(midpoint));
    end
    newdom_k1 = dom;
    newdom_k2 = dom;
    
    if all(obj.intVarIndices ~= branchVarInd)
        newdom_k1(branchVarInd, 2) = midpoint;
        newdom_k2(branchVarInd, 1) = midpoint;
    elseif longestEdge == 1
        %the domain has singular point, expand to ensure interior
        %intersection (variable is integer)
        newdom_k1(branchVarInd, 2) = ceil(midpoint - 1) + 1e-5;
        newdom_k2(branchVarInd, 1) = ceil(midpoint)-1e-5;
    else
        newdom_k1(branchVarInd, 2) = ceil(midpoint - 1);
        newdom_k2(branchVarInd, 1) = ceil(midpoint);
    end
    
    k1 = obj.nodeCtr + 1 + obj.iterInfo.nnew;
    k2 = obj.nodeCtr + 2 + obj.iterInfo.nnew;

    obj.splitCopyNode(k, k1, newdom_k1, k2, newdom_k2);
    
    obj.iterInfo.nnew = obj.iterInfo.nnew + 2;

    %% 6 List management
    % Quite complex...
    % 1. If it was y variable:
    %   1.1 k was selected previously, as well as Lp, so for Lp:
    %   1.2 Remove k, add k1 and k2
    % 2. If it was x variable:
    %   2.1 Iterate through sublists Lps
    %   2.2 For i in 1,2
    %       2.2.1 if X domain of node k_i has common interior points with
    %       any j in Lps\k (for X domain only).
    %           2.2.1.1 Then create new sublist Lps_i = Lps \ k + k_i
    % 3. Use IC and split Lp if necessary
    ppos = obj.partitions.keytopos(p);
    
    if branchVarInd > xdim % var is (x y), so x indices are 1:xdim
        for s = 1:numel(obj.partitions.dict(ppos).Lp)
            mask = obj.partitions.dict(ppos).Lp{s} == k;
            if any(mask) %contains k
                obj.partitions.dict(ppos).Lp{s}(mask) = [];
                obj.partitions.dict(ppos).Lp{s} = [obj.partitions.dict(ppos).Lp{s} k1 k2];
            end
        end
    elseif branchVarInd <= xdim
        nkeys = obj.nodes.keys();
        numOfLps = numel(obj.partitions.dict(ppos).Lp);
        for s = 1:numOfLps %iterate through Lps
            %check if Lps has k
            mask = obj.partitions.dict(ppos).Lp{s} == k;
            if any(mask) %contains k
                %check if we should add a list
                add_ki_Lps = [1; 1];
                Lps = obj.partitions.dict(ppos).Lp{s};
                for j = Lps(Lps ~= k);
                    domj = obj.nodes.dict(nkeys == j).domain;
                    add_ki_Lps = [  hasCommonXInterior(newdom_k1, domj, xdim); ...
                                    hasCommonXInterior(newdom_k2, domj, xdim)] & add_ki_Lps;
                end
                assert(any(add_ki_Lps), 'Logical error, algorithm requires at least one new list to be created');
                add_ki = [k1;k2] .* add_ki_Lps;
                add_ki(add_ki == 0) = [];
                
                % add at least one list and delete previous (by replacing
                % the list) (ATTENTION: cell list is under iteration process)

                new_Lps = [Lps(Lps ~= k) add_ki(1)];
                obj.partitions.dict(ppos).Lp{s} = new_Lps;
                
                % if two lists are added - add to the end
                if numel(add_ki) == 2
                    new_Lps = [Lps(Lps ~= k) add_ki(2)];
                    obj.partitions.dict(ppos).Lp{end+1} = new_Lps;
                end
            end
        end 
    end
    
    %% IC application
    % also complex. 
    % 
    % 1. Check if IC is true
    % 2. If not - skip
    % 3. If true - create new partition and update f_UB
    [ICtrue, Lp1, Lp2] = ICcheck(obj.partitions.dict(ppos).Lp);
    if ICtrue
        k_in = obj.iterInfo.k_in;
        if ~isempty(k_in) && any([Lp2{:}] == k_in)
            obj.splitPartitionByLp(p, Lp2, Lp1);
        else
            obj.splitPartitionByLp(p, Lp1, Lp2);
        end
    end
end

function res =  hasCommonXInterior(dom1, dom2, xdim)
    ind = 1:xdim;
    res = any(dom1(ind,1) < dom2(ind,2) && dom2(ind, 1) < dom1(ind,2));
end

function [possible, set1, set2] = ICcheck(Lp)
    possible = 0;
    set1 = cell(size(Lp));
    set1{1} = Lp{1};
    sptr = 1;
    newIdx = set1{1};
    oldIdx = [];
    searchSet = 2:numel(Lp);
    while ~isempty(newIdx)
        for i = newIdx
            for j = searchSet
                if any(Lp{j} == i)
                    sptr = sptr + 1;
                    set1{sptr} = Lp{j};
                    searchSet(searchSet == j) = [];
                end
            end
        end
        oldIdx = union(oldIdx, newIdx);
        newIdx = setdiff([set1{:}], oldIdx);
    end
    if ~isempty(searchSet)
        possible = 1;
        set1(sptr+1:end) = [];
        set2 = Lp(searchSet);
    else
        set1 = {};
        set2 = {};
    end
end

