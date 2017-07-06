function step1_rootNodeBounds( obj )
%STEP1_ROOTNODEBOUNDS Performs step 1 of BnS (see paper)
%   All information saved in solver class

%% implicit
%obj.addNode(1, 0, obj.domain); %deprecated

%% Step 1 Inner and outer bounds for root node
% Step 1.1 Solve RILB, compute f_LB_(1)
%   if infeasible go to Step 2

    [feas, f_ILB] = obj.Problem.solveRILB();
    if feas == 0
        return;
    end
% Step 1.2 Solve RIUB, get f_UB_(1)
    [~, f_IUB] = obj.Problem.solveRIUB();
    % Step 1.3 Solve LB globally to get F_uscore_(1).
    [feas, F_LB, x_LB] = obj.Problem.solveLB(obj.domain, f_IUB);
    
    %  If infeasible go to Step 2. 
    if feas == 0
        return;
    end
    
    
    % Otherwise if a feasible solution (x_(1), y_(1)) is computed,
    % add node to the universal list L := {1} with
    % properties (f_ILB_(1), f_IUB_(1), F_LB_(1), x_(1), l_(1)),
    % where l_(1) := 0.
    obj.addRootNode(1, 0, obj.domain, f_ILB, f_IUB, F_LB, x_LB);
    obj.appendNodeToL(1);
    
    % Initialize the partition of X, i.e., P:=1 and Xi_1 := X, and
    % generate the first independent list L_1 := {1}.
    % Set the best inner upper bound for Xi_1: f_UB_1 := f_RIUB_(1).
    obj.initPartitions(f_IUB); %list is modified inside
    
    % Step 1.4 Set x_upscore := x_(1) and compute w(x_upscore) using (3).
    [~, w_ISP] = obj.Problem.solveISP(x_LB);
    % Then solve (UB) locally to obtain F_upscore_(1).
    % If feasible solution (x_f, y_f) is obtained, update the incumbent
    % (x_UB, y_UB) = (x_f, y_f) and F_UB = F_upscore_(1).
    [feas, F_UB, y_UB] = obj.Problem.solveUB(w_ISP, x_LB);
    x_UB = x_LB;
    
    if feas == 1
        obj.setBestUB(F_UB, x_UB, y_UB);
    end
    
    if obj.debugLevel >= 1
        fprintf('---------------------------\n');
        fprintf('Step 1: done\n');
        if numel(x_LB) > 0
            pack_x = '*';
        else
            pack_x = num2str(x_LB);
        end
        fprintf('\tRoot node (f_ILB, f_IUB, F_LB, x_LB) = (%d, %d, %d, %s)\n', ...
                f_ILB, f_IUB, F_LB, pack_x );
        
    end


end

