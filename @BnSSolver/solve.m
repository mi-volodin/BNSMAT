function [ F, x, y ] = solve( slv )
%SOLVE dispatching procedure: solves underlying problem
%   The algorithm is meticolously described in the paper
disp('-== BNS Solver start ==-');

disp('ROOT node init');
slv.step1_rootNodeBounds();
try
    while slv.step2_nodeSelection() == 0
%         disp('>> Branching');
        slv.step3_branching();
        
%         disp('>> ILB');
        fl = slv.step4_InnerLowerBound();
        if ~fl
%             disp('>> IUB');
            fl = slv.step5_InnerUpperBound();
        end
        
        if ~fl
%             disp('>> LB');
            fl =  slv.step6_OuterLowerBound();
        end
        
        if ~fl
%             disp('>> UB');
            slv.step7_OuterUpperBound();
        end
        slv.nodeCtr = slv.nodeCtr + slv.iterInfo.nnew;
    end
    if slv.debugLevel >= 1
        disp('bestUB:');
        disp(slv.bestUB);
    end
catch e
    fprintf('Error on iteration %d\n', slv.iterCtr);
    e.rethrow();
end
F = slv.bestUB.F;
x = slv.bestUB.x;
y = slv.bestUB.y;



end

