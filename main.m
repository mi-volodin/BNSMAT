%define problem
clear slv;
clear problemInstance;
clear BnSSolver;
clear propdict;


Co = [-1 -10];
Ao = [];
Bo = [];
ci = [0 1];
ai = [-25 20; 1 2; 2 -1; -2 -10];
bi = [30;10;15;-15];
lc = [0; 0];
uc = [8; 4];

problemInstance = bp_milp(Co, Ao, Bo, ci, ai, bi, [1 2], lc, uc, 1); 
slv = BnSSolver(problemInstance, 5);
%problemInstance.testsolve()
slv.solve();
