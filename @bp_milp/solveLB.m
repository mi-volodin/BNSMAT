function [ feas, F_LB, x_LB, y_LB ] = solveLB( obj, domain, f_UB_p )
%SOLVELB Solves Lower bound of global problem
    dom = [obj.lc obj.uc];
    if nargin > 1
        dom = domain;
    end
    
%     obj.problems.LB.type = 'MILP';
    feas = 0;
    F_LB = -Inf;
    x_LB = [];
    y_LB = [];
    
    obj.problems.LB.sol.feasible = 0;
    
    %% define problem objective
    obj.problems.LB.c = obj.Co;
    
    %% constraints
    
    % G <= 0
    a1 = obj.Ao;
    b1 = obj.Bo;
    
    % g <= 0
    a2 = obj.ai;
    b2 = obj.bi;
    
    % f < f_ub
    a3 = obj.ci;
    b3 = f_UB_p;
%     if exist('obj.problems.RIUB.sol', 'var') == 1 && ~isinf(obj.problems.RIUB.sol.fopt)
%         a3 = obj.ci;
%         b3 = obj.problems.RIUN.sol.fopt;
%     end
    obj.problems.LB.a = [a1; a2; a3];
    obj.problems.LB.buc = [b1; b2; b3];
    
    %% domain
    obj.problems.LB.blx = dom(:, 1);
    obj.problems.LB.bux = dom(:, 2);
    
    %% integer variables index
    obj.problems.LB.ints.sub = obj.ints;
    
    %% solve
    [~, res] = mosekopt('minimize echo(0)', obj.problems.LB, obj.mosek_pars);
    
    if res.rcode ~= 0 
        error ('LB is not ok');
    end
    
    try
        if strcmp(res.sol.int.prosta, 'PRIMAL_FEASIBLE')
            obj.problems.LB.sol.feas = 1;
            feas = 1;
            obj.problems.LB.sol.xopt = res.sol.int.xx;
            obj.problems.LB.sol.fopt = res.sol.int.pobjval;
%             [f_LB, y_LB] = obj.getSolutionLB();
            F_LB = res.sol.int.pobjval;
            x_LB = res.sol.int.xx(1:obj.xdim);
            y_LB = res.sol.int.xx(obj.xdim + (1:obj.ydim));
        end
    catch
        error('Could not get solution');
%         fprintf('MSKERROR: could not get solution');
    end
    
    %% clean
    if ~obj.debug
        obj.clean('LB');
    end
end

