local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Rules=require(Shared.MonetizationRules)
local U=require(Shared.StarUtil)
local Http=game:GetService("HttpService")
local M={}
local function updateBytes(account)
    if account.Runtime then account.Runtime.ReceiptLedgerBytes=#Http:JSONEncode(account.ProcessedReceipts)end
end
function M.ApplyProduct(account,offer,purchaseId,now,maxCurrency)
    local target=account.ActiveSystemId
    local run=account.Systems[target]
    local projected={Currency=run.Currency,PaidBoostEndsAt=account.PaidBoostEndsAt,ProcessedReceipts=account.ProcessedReceipts}
    local updated,receipt=Rules.ApplyProduct(projected,offer,purchaseId,now,maxCurrency)
    local result=U.Clone(account)
    if receipt.Status=="Granted" then
        if receipt.Effect.Type=="Currency" then
            receipt.Effect.SystemId=target;receipt.Effect.Generation=account.DiscoveryGeneration
            result.Systems[target].Currency=updated.Currency
        else result.PaidBoostEndsAt=updated.PaidBoostEndsAt end
        result.ProcessedReceipts[purchaseId]=U.Clone(receipt)
        updateBytes(result)
    end
    return result,receipt
end
function M.ReconcileReceipt(account,receipt)
    local result=U.Clone(account)
    if type(receipt)~="table" or receipt.Status~="Granted" or type(receipt.PurchaseId)~="string"
        or #receipt.PurchaseId==0 or #receipt.PurchaseId>128 or type(receipt.Effect)~="table" then return result end
    if result.ProcessedReceipts[receipt.PurchaseId]then return result end
    local copy=U.Clone(receipt);local e=copy.Effect
    if e.Type=="Currency" then
        e.SystemId=e.SystemId or "Sun";e.Generation=e.Generation or 0
        if not result.UnlockedSystems[e.SystemId] or not U.Finite(e.Amount) or e.Amount<=0 or e.Amount>1e18
            or not U.Finite(e.Generation) or e.Generation%1~=0 or e.Generation<0 or e.Generation>result.DiscoveryGeneration then return result end
        if e.Generation==result.DiscoveryGeneration then
            local run=result.Systems[e.SystemId]
            if run.Currency+e.Amount>1e18 then return result end
            run.Currency+=e.Amount
        end
    elseif e.Type=="PaidBoost" and U.Finite(e.EndsAt) and e.EndsAt>0 then
        result.PaidBoostEndsAt=math.max(result.PaidBoostEndsAt,e.EndsAt)
    else return result end
    result.ProcessedReceipts[copy.PurchaseId]=copy;updateBytes(result)
    return result
end
return M
