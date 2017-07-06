classdef BnSSolver < handle
    %BNSSOLVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        Problem; %source problem
        L ;% = propdict('k'); % should be list and indexes extraction
        L_in ; % = propdict('k');
        nodes ; %= propdict('k');
        partitions ; % = propdict('p');
        %currentUB = struct('x_UB', [], 'y_UB', [], 'F_UB', Inf);
        xdim;
        ydim;
        domain;
        branchRestrictVarInds = [];
        
        iterCtr = 0;
        nodeCtr = 0;
        
        iterInfo;
        
        bestUB = struct('F', Inf, 'x', [], 'y', []);
        solverTerminated = 0;
        
        debugLevel = 0;
        intVarIndices = [];
        
        eps_F = 1e-3;
    end
    
    methods
        function obj = BnSSolver(biLevelProblem, debugLevel)
            %BNSSOLVER class of solver that operates Branch and Sandwich algorithm
            %   Problem is bilevelProblem class
            %   This solver uses single Problem and copy it every 
            %   time the domain should be changed
            
            obj.L = propdict('k');
            obj.L_in = propdict('k');
            obj.nodes = propdict('k');
            obj.partitions = propdict('p');
           
            obj.Problem = biLevelProblem;
            obj.intVarIndices = biLevelProblem.getIntegerVarIndices();
            [obj.domain, obj.xdim, obj.ydim] = biLevelProblem.getDomain();
            if nargin > 1
                obj.debugLevel = debugLevel;
            end
            
            if isprop(biLevelProblem, 'branchRestriction')
                obj.branchRestrictVarInds = biLevelProblem.branchRestriction;
            end
        end
        
        [F, x, y] = solve(obj);
        function [F, x, y] = getSolution(obj)
            if obj.solverTerminated == 0
                disp('Solve the problem first (.solve() method)');
            else
                F = obj.bestUB.F;
                x = obj.bestUB.x;
                y = obj.bestUB.y;
            end
        end
        
        function terminate(obj) %TODO check if it's really required
            %TERMINATE perform cleaning and pretermination tasks
            disp('Solver terminated.');
            obj.solverTerminated = 1;
        end
        
        step1_rootNodeBounds(obj);
        [terminate] = step2_nodeSelection(obj);
        step3_branching(obj);
        [go_to_step2] = step4_InnerLowerBound(obj);
        [go_to_step2] = step5_InnerUpperBound(obj);
        [go_to_step2] = step6_OuterLowerBound(obj);
        step7_OuterUpperBound(obj);
        
        %% solver management
        function setBestUB(obj, F_UB, x_UB, y_UB)
            obj.bestUB.F = F_UB;
            obj.bestUB.x = x_UB;
            obj.bestUB.y = y_UB;
        end
        
        %% node management
        addRootNode(obj, k, l, domain, f_ILB, f_IUB, F_LB, x_LB); 
        splitCopyNode(obj, k, newk1, domain1, newk2, domain2)
        appendNodeToL(obj, k);
        appendNodeToLin(obj, k);
        [k, p] = selectBestNode_k(obj);
        [k_in] = selectBestNode_k_in(obj, Lin_cap_Lp)
        [ppos, p] = getPartitionOfNodes(obj, k);
        [k1, k2] = branchInNode(obj, k, p);
        fathomNodes(obj, ks);
        outerFathomNodes(obj, ks);
        [fathomed_ks] = innerFathomRule(obj, ks);
        listDeletionFathomRule(obj);
        deleteNodesFromLp(obj, ks);
        
        
        %% partitions management
        initPartitions(obj, f_IUB);
        splitPartitionByLp(obj, p, Lp1, Lp2);
        updatePartitionBestIUB(obj, p);
        
    end
    
end

