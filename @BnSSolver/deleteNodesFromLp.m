function  deleteNodesFromLp( obj, ks )
%DELETENODESFROMLP Deletes nodes (ks) from corresponding Lp
%   

for i = 1:obj.partitions.numel()
   Lp = obj.partitions.dict(i).Lp;
   flat = [Lp{:}];
   [mask, idx] = ismember(flat, ks);
   if any(mask)
       idx = idx(mask);
       s_to_fathom = false(size(Lp));
       for s = 1:numel(Lp)
           Lp{s} = Lp{s}(~ismember(Lp{s},ks(idx)));
           if isempty(Lp{s})
               s_to_fathom(s) = true();
           end
       end
       Lp(s_to_fathom) = [];
       obj.partitions.dict(i).Lp = Lp;
   end
end


end

