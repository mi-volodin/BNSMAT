function [ feas, f_RIUB, y_RIUB ] = solveRIUB( obj, domain )
%SOLVERIUB Summary of this function goes here
%   Detailed explanation goes here
    
    dom = [obj.lc obj.uc];
    if nargin > 1
        dom = domain;
    end
    
    feas = 0;
    f_RIUB = Inf;
    y_RIUB = [];

    obj.problems.RIUB.type = 'MILP';
    obj.problems.RIUB.sol.feasible = 0;
    %% overestimate functions

    % all functions are considered to be linear (affine)
    xdim = obj.xdim;
    ydim = obj.ydim;

    A = obj.ai(:, 1:xdim);
    c = obj.ci(1:xdim);
    xmin = dom(1:xdim, 1);
    xmax = dom(1:xdim, 2);

    % the idea is: A * (x y) = A_x * x + A_y * y <= 0
    % A_y * y + g_overest <= 0
    g_overest = min(A,0) * xmin + max(A, 0) * xmax;
    % same with c
    f_overest = sum(min(c, 0) * xmin) + sum(max(c, 0) * xmax);

    %now check if bmod has inf
    if any( isinf(g_overest(g_overest > 0))) || (f_overest > 0 && isinf(f_overest))
        error('Upper bound couldn''be estimated');
    end

    % the t variable will be first

    obj.problems.RIUB.c = [1 zeros(1, ydim)];
    ncon = size(obj.ai, 1);
    a1 = [zeros(ncon, 1)  obj.ai( :, xdim + (1 : ydim))];
    a2 = [-1 obj.ci(xdim + (1 : ydim))];
    obj.problems.RIUB.a = [a1; a2];
    b1 = obj.bi - g_overest;
    b2 = - f_overest;
    obj.problems.RIUB.buc = [b1; b2];
    obj.problems.RIUB.blx = [-Inf; dom( xdim + (1 : ydim), 1)];
    obj.problems.RIUB.bux = [ Inf; dom( xdim + (1 : ydim), 2)];

    obj.problems.RIUB.ints.sub = obj.ints(obj.ints > xdim) - xdim + 1;

    [~, res] = mosekopt('minimize echo(0)', obj.problems.RIUB, obj.mosek_pars);

    if res.rcode == 0 && strcmp(res.sol.int.prosta, 'PRIMAL_INFEASIBLE') == 1
        % this is a special branch that replaces +Inf approximation of
        % upper bound for inner objective using the linearity feature and
        % domain limits.
        if isempty(obj.fRIUB_max)
            cy = obj.ci(xdim + (1:ydim));
            ymin = obj.lc(xdim + (1:ydim));
            ymax = obj.uc(xdim + (1:ydim)); 
            cymask = cy > 0;
            f_max = sum(cy(cymask) * ymax(cymask))...
                  + sum(cy(~cymask) * ymin(~cymask)) + f_overest;
            if isnan(f_max) || (f_max < 0 && isinf(f_max))
                f_max = Inf;
            end
            obj.problems.RIUB.sol.xopt = [];
            obj.problems.RIUB.sol.fopt = f_max;
            obj.fRIUB_max = f_max;
        end
        f_RIUB = obj.fRIUB_max;
    elseif strcmp(res.sol.int.prosta, 'PRIMAL_FEASIBLE')
        obj.problems.RIUB.sol.feas = 1;
        feas = 1;
        obj.problems.RIUB.sol.xopt = res.sol.int.xx;
        obj.problems.RIUB.sol.fopt = res.sol.int.pobjval;
%         [f_RIUB, y_RIUB] = obj.getSolutionRIUB();
        f_RIUB = res.sol.int.pobjval;
        y_RIUB = res.sol.int.xx(2:end);
    end
    
    %% CLEAN
    if ~obj.debug
        obj.clean('RIUB');
    end
end

