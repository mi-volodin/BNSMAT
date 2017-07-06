function updatePartitionBestIUB( obj, ppos )
%UPDATEPARTITIONBESTIUB Updates f_UB_p ("Best inner upper bound")
%   Due to some partition changes it should be refreshed 
    Lp = obj.partitions.dict(ppos).Lp;

    LpsMinUb = inf(numel(Lp),1);
    nodesInLp = unique(sort([Lp{:}]));

    nodesInLpUB = [obj.nodes.dict(ismember(obj.nodes.keys(), nodesInLp)).f_IUB];

    for i = 1:numel(Lp)
        LpsMinUb(i) = min(LpsMinUb(i), min(nodesInLpUB(ismember(nodesInLp, Lp{i}))));
    end

    bestUB = max(LpsMinUb);
    assert(bestUB - obj.Problem.eps_f < obj.partitions.dict(ppos).f_IUB, 'Logic error: after branching UB couldn''t increase');
    obj.partitions.dict(ppos).f_IUB = bestUB;
end

