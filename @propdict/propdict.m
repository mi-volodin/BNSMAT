classdef propdict < handle
    %PROPDICT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dict = struct([]);
        keyisdouble = 1;
        keyfield = '';
    end
    
    methods
        function dc = propdict(keyfield, struct, keyisdouble)
            if nargin == 1
                dc.keyfield = keyfield;
            elseif nargin > 1
                assert(isstruct(struct), 'First argument should be structure');
                assert(isfield(struct, keyfield), 'Second argument should be a valid structure field');
                dc.dict = struct;
                dc.keyfield = keyfield;
                if nargin == 3
                    dc.keyisdouble = keyisdouble;
                end
            else
                error('At least keyfield required');
            end
        end
        
%         function res = subsref(dc, S)
%             if strcmp(S(1).type, '.') && ischar(S(1).subs)
%                 switch(S(1).subs)
%                     case 'keys'
%                         res = keys(dc);
%                     otherwise
%                         error('Unknown method')
%                 end
%             else
%                 res = subsref(dc.dict, S);
%             end
%         end
%         
%         function dc = subsasgn(dc,S,b)
%             dc.dict = subsasgn(dc.dict, S, b);
%         end
        
        function ks = keys(dc)
        %KEYS return cell array (or vector if key is double)
            if numel(dc.dict) == 0 
                ks = [];
                return;
            end
            if dc.keyisdouble
                ks = [dc.dict.(dc.keyfield)];
                if numel(ks) < numel(dc.dict)
                    warning('It seems that keys are not numeric, keyisdouble set to false');
                    dc.keyisdouble = 0;
                else
                    return;
                end
            end
            if ~dc.keyisdouble    
                ks = {dc.dict.(dc.keyfield)};
            end
        end   
        
        function n = numel(dc)
        %NUMEL returns number of elements in dictionary
            n = numel(dc.dict);
        end
        
        function add(dc, struct_array)
        %ADD adds new element to dictionary
            n = numel(struct_array);
            if n > 1
                error('Unimplemented multiple insertion')
            else
                newpos = numel(dc.dict) + 1;
                assert(isfield(struct_array, dc.keyfield), 'No key field (%s) presented', dc.keyfield);
                assert(~any(struct_array.(dc.keyfield) == dc.keys()), 'Duplicate key value, cannot insert');
                if newpos == 1
                    dc.dict = struct_array;
                else
                    dc.dict(newpos) = struct_array;
                end
            end
        end
        
        function res = isempty(dc)
            res =  numel(dc.dict) == 0;
        end
        
        function removeByKey(dc, keys)
            if isempty(keys)
                return;
            end
            dictkeys = dc.keys();
            mask = [];
            if ~iscell(dictkeys)
                mask = ismember(dictkeys, keys);
            else
                mask = zeros(1,numel(dictkeys));
                for i = 1:numel(dictkeys)
                    mask(i) = dictkeys{i} == keys;
                end
            end
            if any(mask)
                dc.dict(mask) = [];
            end
        end
        
        function res = getByKey(dc, key)
            if obj.keyisdouble
                res = dc(dc.keys() == key);
            else
                for i = 1:numel(dc)
                    if key == dc(i).(dc.keyfield)
                        res = dc(i);
                        return;
                    end
                end
            end
        end
        
        function pos = keytopos(dc, keys)
            pos = zeros(size(keys));
            if dc.keyisdouble
                dckeys = dc.keys();
                [mask, idx] = ismember(dckeys, keys);
                line = 1:numel(dckeys);
                pos(idx(mask)) = line(mask);
            else
                for i = 1:numel(dc)
                    m = keys == dc(i).(dc.keyfield);
                    if any(m)
                        pos(m) = i;
                    end
                end
            end
            if any(pos == 0)
                error('No such key in dictionary')
            end
        end
    end
    
end

