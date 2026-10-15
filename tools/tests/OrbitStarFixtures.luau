local F={}
function F.Clone(value)
    if type(value)~="table" then return value end
    local copy={};for k,v in pairs(value)do copy[k]=F.Clone(v)end;return copy
end
function F.Store(initial)
    local s={Value=F.Clone(initial),Writes=0}
    function s:UpdateAsync(key,callback)
        local nextValue=callback(F.Clone(self.Value))
        if nextValue~=nil then self.Value=F.Clone(nextValue);self.Writes+=1 end
        if self.ThrowAfterWrite then self.ThrowAfterWrite=false;error("simulated response loss")end
        return F.Clone(nextValue)
    end
    return s
end
return F
