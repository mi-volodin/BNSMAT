function [ feas, f_UB, y_UB ] = solveUB( obj, w_ISP, x_LB, domain )
%SOLVEUB Solve upper bound for global problem
%   This is the 'y'-problem only, x is taken from LB
%   and _w_ is taken as optimum of ISP

    %% defaults
    dom = [obj.lc obj.uc];
    if nargin == 4
        dom = domain;
    end
    
    feas = 0;
    obj.problems.UB.sol.feas = 0;
    f_UB = +Inf;
%     x_UB = [];
    y_UB = [];

    obj.problems.UB.type = 'MILP';
    %% preliminary
    xdim = obj.xdim;
    ydim = obj.ydim;
    xind = 1:xdim;
    yind = xdim + (1:ydim);
    
    %% select x from LB problem and w from ISP
    x_part = x_LB; %obj.problems.LB.sol.xopt(xind);
    w = w_ISP; %obj.problems.ISP.sol.fopt;
    
    %% formulate problem

    %extract x,y part from F and G (outer functions)
    FX_part = obj.Co(xind);%useless due to LP nature
    if ~isempty(obj.Ao)
        GX_part = obj.Ao(:, xind);
        GY_part = obj.Ao(:, yind);
    else
        GX_part = zeros(1, size(x_part, 1));
        GY_part = [];
    end
    
    FY_part = obj.Co(yind); 
    
    %same with inner
    fx_part = obj.ci(xind); %linear functional
    gx_part = obj.ai(:, xind);

    fy_part = obj.ci(yind);
    gy_part = obj.ai(:, yind);

    %formulate functional
    obj.problems.UB.c = FY_part;
    obj.problems.UB.a = [GY_part; gy_part; fy_part];

    obj.problems.UB.buc = [ obj.Bo - GX_part * x_part; ...
                            obj.bi - gx_part * x_part; ...
                            w + obj.eps_f - fx_part * x_part];
    
    obj.problems.UB.blx = dom(yind, 1);
    obj.problems.UB.bux = dom(yind, 2);

    obj.problems.UB.ints.sub = obj.ints(obj.ints > xdim) - xdim;

    [~, res] = mosekopt('minimize echo(0)', obj.problems.UB, obj.mosek_pars);

    try
        if strcmp(res.sol.int.prosta, 'PRIMAL_FEASIBLE')
            obj.problems.UB.sol.xopt = res.sol.int.xx;
            obj.problems.UB.sol.fopt = res.sol.int.pobjval + FX_part * x_part;
            
            feas = 1;
            obj.problems.UB.sol.feas = 1;
            
%             [f_UB, y_UB] = obj.getSolutionUB();
            f_UB = obj.problems.UB.sol.fopt;
            y_UB = res.sol.int.xx;
        end
    catch err
        error(err.message);
        fprintf('MSKERROR: Could not get solution');
    end

    %% clean
    if ~obj.debug
        obj.clean('UB');
    end
end
