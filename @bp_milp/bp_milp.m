classdef bp_milp < bilevelProblem
    %BP_MILP bilevelProblem with MILP inner and MILP outer* problems
    %   The outer problem is MILP if we exclude inner problem from
    %   constraints
    
    % problem is
    % <Co, (x y)> -> min
    %   Ao (x y) <= Bo
    %   <ci, (x y)> -> min
    %       ai (x y) <= bi
    %       (x y) in ints are integers
    %       lc <= (x y) <= uc
    
    %       (x y)[1:xdim] are 'x'-s
    %       (x y)[xdim + 1: ydim] are 'y'-s
    properties
        Co = []; 
        Ao = [];
        Bo = [];
        ci = [];
        ai = [];
        bi = [];
        xdim = 0;
        ydim = 0;
        ints = [];
        lc = [];
        uc = [];
        branchRestriction = [];
        
        
        problems;
        
        eps_f = 1e-5;
        fRIUB_max = [];
        
    end
    
    properties (Constant, Access= private)
       debug = 0; %toggle this to 1 to save bounding problem formulations
       fields_to_clear = {'type', 'c', 'a', 'b', 'buc', 'blx', 'bux', 'ints'};
       problem_names = {'RILB', 'RIUB', 'LB', 'ISP', 'UB'};
       mosek_pars = struct('MSK_IPAR_LOG', 0, 'MSK_IPAR_LOG_HEAD', 0);
    end
    
    methods
        function obj = bp_milp(Co, Ao, Bo, ci, ai, bi, ints, lc, uc, xdim)
            obj.Co = Co(:)';
            obj.Ao = Ao;
            if ~isempty(Bo)
                obj.Bo = Bo(:);
            end
            if isempty(ci)
                error('The problem should be bilevel');
            end
            obj.ci = ci(:)';
            if ~isempty(ai)
                obj.ai = sparse(ai);
                obj.bi = bi(:);
            end
            obj.ints = ints;
            
            obj.xdim = xdim;
            obj.ydim = numel(Co) - xdim;  
            
            if ~isempty(lc)
                obj.lc = lc(:);
            else
                obj.lc = -inf(numel(Co));
            end
            
            if ~isempty(uc)
                obj.uc = uc(:);
            else
                obj.uc = inf(obj.xdim + obj.ydim);
            end
           
            obj.lc(ints) = fix(obj.lc(ints));
            obj.uc(ints) = fix(obj.uc(ints));
        end
        
        function copy = copy(obj, newDomain)
            if nargin == 1
                copy = bp_milp(obj.Co, obj.Ao, obj.Bo, obj.ci, obj.ai, ...
                    obj.bi, obj.ints, obj.lc, obj.uc, obj.xdim);
            else
                copy = bp_milp(obj.Co, obj.Ao, obj.Bo, obj.ci, obj.ai, ...
                    obj.bi, obj.ints, newDomain(:,1), newDomain(:,2), obj.xdim);
            end
        end
        
        function clean(obj, probname)
            if nargin == 1
                probnames = obj.problem_names;
            else
                probnames = {probname};
            end
            for i = 1:numel(probnames)
                if isfield(obj.problems, obj.problem_names{i})
                    obj.problems.(obj.problem_names{i}) = [];
                end
            end
        end
        
        function restrictBranching(obj, indices)
           dim = obj.xdim + obj.ydim;
           if numel(indices) < dim
               filt = indices > dim;
               if any(filt)
                   warning('Restrictions with index greater than var dim - removed');
                    indices(filt) = [];
               end
%                assert(isempty(intersect(indices, obj.ints)), 'Currently cannot restrict branching on integers');
               obj.branchRestriction = indices;
           else
            warning('Cannot restrict branching on all variables');
           end
        end
        
%         obj = solveMILP(obj);
        [feas, f_RILB, x_RILB, y_RILB] = solveRILB(obj, domain);
        [feas, f_RIUB, y_RIUB] = solveRIUB(obj, domain);
        [feas, f_LB, x_LB, y_LB] = solveLB(obj, domain, f_UB_p);
        [feas, f_ISP, y_ISP] = solveISP(obj, x, domain);
        [feas, f_UB, y_UB] = solveUB(obj, x_LB, w_ISP, domain);
        
%         function [f, x, y] = getSolution(obj, probname)
%             try
%                 f = obj.problems.(probname).sol.fopt;
%                 x = [];
%                 y = [];
%                 if ~isempty(obj.problems.(probname).sol.xopt)
%                     switch probname
%                         case {'ISP', 'UB'}
%                             y = obj.problems.(probname).sol.xopt;
%                         case {'RILB', 'LB'}
%                             x = obj.problems.(probname).sol.xopt(1:obj.xdim);
%                             y = obj.problems.(probname).sol.xopt(obj.xdim + (1:obj.ydim));
%                         case {'RIUB'}
%                             y = obj.problems.(probname).sol.xopt(2:end);
%                         otherwise
%                             error('Unimplemented problem %s', probname);
%                     end     
%                 end
%             catch
%                 error('Couldn''t obtain required informtion.')
%             end
%         end
        
%         function [f_RILB, x_RILB, y_RILB] = getSolutionRILB(obj)
%             [f_RILB, x_RILB, y_RILB] = obj.getSolution('RILB');
%         end
%         
%         function [f_RIUB, y_RIUB] = getSolutionRIUB(obj)
%             [f_RIUB, ~, y_RIUB] = obj.getSolution('RIUB');
%         end
%         
%         function [F_LB, x_LB, y_LB] = getSolutionLB(obj)
%             [F_LB, x_LB, y_LB] = obj.getSolution('LB');
%         end
%         
%         function [F_UB, y_UB] = getSolutionISP(obj)
%             [F_UB, ~, y_UB] = obj.getSolution('ISP');
%         end
%         
%         function [f_UB, y_UB] = getSolutionUB(obj)
%             [f_UB, ~, y_UB] = obj.getSolution('UB');
%         end
        
%         function [dom] = getDomainX(obj)
%         %%GETDOMAINX get the domain of X
%           dom = [obj.lc(1:obj.xdim) obj.uc(1:obj.xdim)];
%         end
        
        function [dom, xdim, ydim] = getDomain(obj)
        %%GETDOMAIN get the domain of X and Y
          dom = [obj.lc obj.uc];
          xdim = obj.xdim;
          ydim = obj.ydim;
        end
        
%         function [dom] = getDomainStruct(obj)
%         %%GETDOMAINSTRUCT get the domain of X and Y
%           dom.x = [obj.lc(1:obj.xdim) obj.uc(1:obj.xdim)];
%           dom.y = [obj.lc(obj.xdim + (1:obj.ydim)) obj.uc(obj.xdim + (1:obj.ydim))];
%         end
        
        function [inds] = getIntegerVarIndices(obj)
        %%GETINTEGERVARINDICES returns indices of variables in the adjoint
        %%[x y] vector that has integrality constraint on it.
            inds = obj.ints;
        end
        
    end
    
end

