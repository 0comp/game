local U={}
function U.Clone(value)
    if type(value)~="table" then return value end
    local result={};for k,v in pairs(value)do result[k]=U.Clone(v)end
    return result
end
function U.Finite(value)
    return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge
end
return U
