clear;
case_mat = 'ExampleMatrices/2_bus_case1-2.mat';

load(case_mat);

varline = 1:numel(Ci);
outmask = ismember(varline, outer);
inmask = ~outmask;
intmask = ismember(varline, intcon);

Co = [Co(outmask); Co(inmask)]';
Aoineq = [Aoineq(:, outmask), Aoineq(:, inmask)];

Ci = [Ci(outmask); Ci(inmask)]';
Aineq = [Aineq(:, outmask), Aineq(:, inmask)];

lb = [lb(outmask); lb(inmask)];
ub = [ub(outmask); ub(inmask)];

intmask = [intmask(outmask), intmask(inmask)];
intcon = varline(intmask);



xdim = numel(outer);

prb = bp_milp(Co, Aoineq, Boineq, Ci, Aineq, Bineq, intcon, lb, ub, xdim);
bns = BnSSolver(prb, 10);
