local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local U=require(Shared.StarUtil)
local Http=game:GetService("HttpService")
local Store={MaxCharacters=3800000}
local function validArguments(store,key,session,revision,op,now,leaseSeconds)
    return store and type(store.UpdateAsync)=="function" and type(key)=="string" and #key>0
        and type(session)=="string" and #session>0 and U.Finite(revision) and revision>=0 and revision<=9e15 and revision%1==0
        and type(op)=="string" and #op>0 and #op<=160 and U.Finite(now) and U.Finite(leaseSeconds) and leaseSeconds>0
end
local function owns(old,session,now)
    return type(old)=="table" and type(old._Session)=="table" and old._Session.Id==session
        and U.Finite(old._Session.ExpiresAt) and old._Session.ExpiresAt>now
        and (old.Version==nil or old.Version==1 or old.Version==2 or old.Version==3)
end
local function payload(snapshot,base,marker,session,now,seconds)
    if type(snapshot)~="table" or snapshot.Version~=3 then return nil end
    local copy=U.Clone(snapshot)
    copy.Revision=base+1;copy.LastOperationId=marker
    copy._Session={Id=session,ExpiresAt=snapshot._ReleaseSession==true and 0 or now+seconds}
    copy._ReleaseSession=nil
    local ok,text=pcall(function()return Http:JSONEncode(copy)end)
    if not ok or #text>Store.MaxCharacters then return nil end
    return copy
end
function Store.Commit(store,key,session,base,proposed,operationId,now,seconds)
    if not validArguments(store,key,session,base,operationId,now,seconds) then return "Conflict"end
    local nextValue=payload(proposed,base,operationId,session,now,seconds)
    if not nextValue then return "Capacity"end
    local status="Conflict"
    local ok,saved=pcall(function()
        return store:UpdateAsync(key,function(old)
            status="Conflict"
            if type(old)=="table" and type(old._Session)=="table" and old._Session.Id==session and old.LastOperationId==operationId then status="Committed";return old end
            if not owns(old,session,now)then return nil end
            if (old.Revision or 0)~=base then return nil end
            status="Committed";return U.Clone(nextValue)
        end)
    end)
    if not ok then return "Retry"end
    if status=="Committed" and type(saved)=="table" and saved.LastOperationId==operationId then return "Committed",saved end
    return status,saved
end
function Store.Resolve(store,key,session,base,operationId,rollback,now,seconds)
    if not validArguments(store,key,session,base,operationId,now,seconds)then return "Conflict"end
    local cancellation="cancel:"..operationId
    local cancelled=payload(rollback,base,cancellation,session,now,seconds)
    if not cancelled then return "Capacity"end
    local status="Conflict"
    local ok,saved=pcall(function()
        return store:UpdateAsync(key,function(old)
            status="Conflict"
            if type(old)=="table" and type(old._Session)=="table" and old._Session.Id==session then
                if old.LastOperationId==operationId then status="Committed";return old end
                if old.LastOperationId==cancellation then status="NotCommitted";return old end
            end
            if not owns(old,session,now)then return nil end
            if (old.Revision or 0)~=base then return nil end
            status="NotCommitted";return U.Clone(cancelled)
        end)
    end)
    if not ok then return "Retry"end
    if type(saved)=="table" then
        if status=="Committed" and saved.LastOperationId==operationId then return status,saved end
        if status=="NotCommitted" and saved.LastOperationId==cancellation then return status,saved end
    end
    return "Conflict"
end
return Store
