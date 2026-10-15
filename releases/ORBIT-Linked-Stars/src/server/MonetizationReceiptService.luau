-- Atomic Developer Product receipt commits against the current profile lease.
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit"):WaitForChild("MonetizationRules"))
local HttpService = game:GetService("HttpService")
local MAX_PROFILE_CHARACTERS = 3_800_000
local Legacy = {}

function Legacy.Commit(store, userId, sessionId, profileSnapshot, offer, purchaseId, gameNow, leaseNow, maxCurrency, leaseSeconds, maxProfileCharacters)
	maxProfileCharacters = type(maxProfileCharacters) == "number" and maxProfileCharacters > 0 and maxProfileCharacters or MAX_PROFILE_CHARACTERS
	if not store or type(store.UpdateAsync) ~= "function"
		or type(userId) ~= "number" or type(sessionId) ~= "string"
		or type(profileSnapshot) ~= "table" or type(offer) ~= "table" or offer.Kind ~= "Product"
		or type(offer.Id) ~= "number" or offer.Id <= 0 or offer.Id % 1 ~= 0
		or type(purchaseId) ~= "string" or type(leaseNow) ~= "number"
		or type(leaseSeconds) ~= "number" or leaseSeconds <= 0 then
		return "Retry"
	end

	local callbackStatus
	local ok, saved = pcall(function()
		return store:UpdateAsync("User_" .. tostring(userId), function(old)
			if type(old) ~= "table" then
				callbackStatus = "Retry"
				return nil
			end
			if old.Version ~= nil and old.Version ~= 1 and old.Version ~= 2 then callbackStatus = "Retry"; return nil end
			local lease = old._Session
			if type(lease) ~= "table" or lease.Id ~= sessionId
				or type(lease.ExpiresAt) ~= "number" or lease.ExpiresAt <= leaseNow then
				callbackStatus = "Retry"
				return nil
			end

			local oldReceipts = old.ProcessedReceipts
			local existing = type(oldReceipts) == "table" and oldReceipts[purchaseId]
			if existing ~= nil then
				if type(existing) == "table" and existing.Status == "Granted" and existing.PurchaseId == purchaseId
					and (existing.ProductId == nil or existing.ProductId == offer.Id) then
					callbackStatus = "Duplicate"
					return old
				end
				callbackStatus = "Retry"
				return nil
			end

			local updated, result = Rules.ApplyProduct(profileSnapshot, offer, purchaseId, gameNow, maxCurrency)
			if result.Status == "Deferred" then
				callbackStatus = "Deferred"
				return nil
			end
			if result.Status == "Invalid" then
				callbackStatus = "Invalid"
				return nil
			end
			if result.Status == "Duplicate" then
				updated._Session = { Id = sessionId, ExpiresAt = leaseNow + leaseSeconds }
				callbackStatus = "Duplicate"
				return updated
			end
			if result.Status ~= "Granted" then
				callbackStatus = "Retry"
				return nil
			end

			updated._Session = { Id = sessionId, ExpiresAt = leaseNow + leaseSeconds }
			local encodedOk, encoded = pcall(function() return HttpService:JSONEncode(updated) end)
			if not encodedOk or #encoded > maxProfileCharacters then
				callbackStatus = "Capacity"
				return nil
			end
			callbackStatus = "Granted"
			return updated
		end)
	end)

	if not ok then return "Retry" end
	if type(saved) ~= "table" then return callbackStatus or "Retry" end
	local receipts = saved.ProcessedReceipts
	local receipt = type(receipts) == "table" and receipts[purchaseId]
	if type(receipt) ~= "table" or receipt.Status ~= "Granted" or receipt.PurchaseId ~= purchaseId then
		return callbackStatus == "Deferred" and "Deferred" or "Retry"
	end
	if callbackStatus == "Duplicate" then return "Duplicate", receipt end
	return "Granted", receipt
end

-- Version 3 delivery persists the complete account and a single root receipt ledger.
local AccountProducts = require(script.Parent.AccountMonetization)
local AccountStore = require(script.Parent.AccountStore)
local U = require(game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit").StarUtil)
local Service = {}
function Service.Commit(store,userId,sessionId,snapshot,offer,purchaseId,gameNow,leaseNow,maxCurrency,leaseSeconds,maxCharacters)
    if type(snapshot)~="table" then return "Retry" end
    if snapshot.Version~=3 then
        if snapshot.Version~=nil and snapshot.Version~=1 and snapshot.Version~=2 then return "Retry" end
        return Legacy.Commit(store,userId,sessionId,snapshot,offer,purchaseId,gameNow,leaseNow,maxCurrency,leaseSeconds,maxCharacters)
    end
    if not store or type(store.UpdateAsync)~="function" or type(userId)~="number" or type(purchaseId)~="string" then return "Retry" end
    local proposed,receipt=AccountProducts.ApplyProduct(snapshot,offer,purchaseId,gameNow,maxCurrency)
    if receipt.Status=="Deferred" or receipt.Status=="Invalid" then return receipt.Status end
    local duplicate
    local proxy={}
    function proxy:UpdateAsync(key,callback)
        return store:UpdateAsync(key,function(old)
            local lease=type(old)=="table" and old._Session
            local prior=type(old)=="table" and type(old.ProcessedReceipts)=="table" and old.ProcessedReceipts[purchaseId]
            if prior~=nil then
                if type(lease)=="table" and lease.Id==sessionId and type(lease.ExpiresAt)=="number" and lease.ExpiresAt>leaseNow
                    and type(prior)=="table" and prior.Status=="Granted" and prior.PurchaseId==purchaseId
                    and (prior.ProductId==nil or prior.ProductId==offer.Id) then
                    duplicate=U.Clone(prior);return old
                end
                return nil
            end
            return callback(old)
        end)
    end
    local status,saved=AccountStore.Commit(proxy,"User_"..tostring(userId),sessionId,snapshot.Revision or 0,proposed,"receipt:"..purchaseId,leaseNow,leaseSeconds)
    if duplicate then return "Duplicate",duplicate,saved end
    if status=="Capacity" then return "Capacity" end
    if status~="Committed" then return "Retry" end
    local granted=saved.ProcessedReceipts[purchaseId]
    if not granted then return "Retry" end
    return "Granted",granted,saved
end
return Service
