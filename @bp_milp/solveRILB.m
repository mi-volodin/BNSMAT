function [ feas, f_RILB, x_RILB, y_RILB ] = solveRILB( obj, domain )
%SOLVERILB Solve Relaxed Inner Lower Bound problem
%   Returns 1 if feasible, than [...f,x,y] values
%   See p.3.2 in the PAPER BnS
    dom = [obj.lc obj.uc];
    if nargin > 1
        dom = domain;
    end
    feas = 0;
    f_RILB = Inf;
    x_RILB = [];
    y_RILB = [];
    
   %% formulate problem
    obj.problems.RILB.type = 'MILP';
    
    obj.problems.RILB.c = obj.ci;
    obj.problems.RILB.a = obj.ai;
    obj.problems.RILB.b = obj.bi;  
    obj.problems.RILB.buc = obj.bi; 
    obj.problems.RILB.blx = dom(:, 1); 
    obj.problems.RILB.bux = dom(:, 2);
    obj.problems.RILB.ints.sub = obj.ints;
    
    %% solve
    % for data structure info see 
    % http://docs.mosek.com/7.0/toolbox/Command_reference.html#CH:MATLAB:SEC:DATSTRUC
    [~, res] = mosekopt('minimize echo(0)', obj.problems.RILB, obj.mosek_pars);
    obj.problems.RILB.sol.feas = 0;
    try
        if strcmp(res.sol.int.prosta, 'PRIMAL_FEASIBLE')
            obj.problems.RILB.sol.feas = 1;
            feas = 1;
            obj.problems.RILB.sol.xopt = res.sol.int.xx;
            obj.problems.RILB.sol.fopt = res.sol.int.pobjval;
%             obj.problems.RILB = rmfield(obj.problems.RILB, obj.fields_to_clear);
            f_RILB = res.sol.int.pobjval;
            x_RILB = res.sol.int.xx(1:obj.xdim);
            y_RILB = res.sol.int.xx(obj.xdim + (1:obj.ydim));
        end     
    catch
        fprintf('MSKERROR: Could not get solution');
    end
    
    %% clean
    if ~obj.debug
        obj.clean('RILB');
    end
end

