function [ feas, f_ISP, y_ISP ] = solveISP( obj, fixed_x, domain )
%SOLVEISP Solves miniproblem for selection
% this is the 'y'-problem only, x is taken from
% LB problem.
    dom = [obj.lc obj.uc];
    if nargin > 2
        dom = domain;
    end
    if nargin == 1
        error ('X value should be supplied');
    end
    
    %% defaults
    feas = 0;
    f_ISP = +Inf;
    y_ISP = [];

    %% preliminaries
    obj.problems.ISP.sol.feas = 0;
    obj.problems.ISP.type = 'MILP';

    xdim = obj.xdim;
    ydim = obj.ydim;
    xind = 1:xdim;
    yind = xdim + (1:ydim);

    %% select x from LB problem
    x_part = fixed_x;

    %% formulate problem
    fx_part = obj.ci(xind); %linear functional
    gx_part = obj.ai(:, xind);

    fy_part = obj.ci(yind);
    gy_part = obj.ai(:, yind);

    obj.problems.ISP.c = fy_part;
    obj.problems.ISP.a = gy_part;

    obj.problems.ISP.buc = obj.bi - gx_part * x_part;
    obj.problems.ISP.blx = dom(yind, 1);
    obj.problems.ISP.bux = dom(yind, 2);

    obj.problems.ISP.ints.sub = obj.ints(obj.ints > xdim) - xdim;

    %% solve and save solution
    [~, res] = mosekopt('minimize echo(0)', obj.problems.ISP, obj.mosek_pars);

    try
        if strcmp(res.sol.int.prosta, 'PRIMAL_FEASIBLE')
            obj.problems.ISP.sol.xopt = res.sol.int.xx;
            obj.problems.ISP.sol.fopt = res.sol.int.pobjval + fx_part * x_part;
            feas = 1;
            obj.problems.ISP.sol.feas = 1;
%             [f_ISP, y_ISP] = obj.getSolutionISP();
            f_ISP = obj.problems.ISP.sol.fopt;
            y_ISP = res.sol.int.xx;
        end
    catch
        error('Could not get solution');
%         fprintf('MSKERROR: Could not get solution');
    end
    
    if ~obj.debug
        obj.clean('ISP')
    end

end

