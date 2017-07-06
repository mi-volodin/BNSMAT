# BNSMAT

This project is an example implementation of Branch and Sandwich algorithm in Matlab for bi-level MILP problems.
The usage is provided by `main.m`

The algorithm is implemented for scientific applications and, in fact, is not applicable to the real field cases, since MATLAB is not a good choice for it.

*When the Julia implementation will be ready - I will put the link here.*

## Example

```Matlab
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
slv = BnSSolver(problemInstance);
slv.solve();
```

## Adding new classes of problems

BnS itself is a management strategy. Any kind of problem should be accompanied with a solver for five types of problems. In case of MILP it could be done in general, however some MINLP problems might require additional tuning.

The interface is described in `@bilevelProblem` class which should be inherited.
Unfortunately, it is described partially at this moment (`TODO`)

