classdef (Abstract) bilevelProblem < handle
    %PROBLEM interface class to general problem
    %   Interface requirements for the problem to be accepted by Branch and
    %   Sandwich algorithm.

    
    methods (Abstract)
        %Every solver accepts the domain as an (OPTIONAL) argument that
        %constraints the value for variables. The domain has the form
        %of Nx2 matrix where first column is lowest values and second
        %column is highest.
        %The output depends on the context.
        [feas, f_RILB, x_RILB, y_RILB] = solveRILB(obj, domain);
            %solveRILB performs the solution of inner lower bound problem.
            %Briefly speaking - it's the inner problem only solved for both
            %inner and outer variables (x and y) where all non-linear
            %elements are replaced with conves underestimators. For linear
            %or conic problems - it's just inner problem without
            %reformulation.
            % feas = 1 if feasible, 0- otherwise.
            % f_RILB - functional optimal value, +Inf if infeasible.
            % x_RILB, y_RILB - vectors (row or col?) of variables at optimum
        [feas, f_RIUB, y_RIUB] = solveRIUB(obj, domain);
            %solveRIUB performs the solution of inner upper bound problem.
            %This problem is outer variables only optimization (y), x are
            %replaced at the manner to guarantee overestimation of every
            %constraint/functional term to be max_(x) at every y. For LP
            %and QP it could be done manually.
            % feas = 1 if feasible, 0- otherwise.
            % f_RIUB - functional optimal value, +Inf if infeasible.
            % y_RIUB - vectors (row or col?) of variables at optimum
        [feas, f_LB, x_LB, y_LB] = solveLB(obj, domain, f_UB_p);
        [feas, f_ISP, y_ISP] = solveISP(obj, x, domain);
        [feas, f_UB, y_UB] = solveUB(obj, x_LB, w_ISP, domain);
        [dom, xdim, ydim] = getDomain(obj);
        [inds] = getIntegerVarIndices(obj);
    end
    
end

