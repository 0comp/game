-- Atomic Developer Product receipt commits against the current profile lease.
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit"):WaitForChild("MonetizationRules"))
local HttpService = game:GetService("HttpService")
local MAX_PROFILE_CHARACTERS = 3_800_000
local Service = {}

function Service.Commit(store, userId, sessionId, profileSnapshot, offer, purchaseId, gameNow, leaseNow, maxCurrency, leaseSeconds, maxProfileCharacters)
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

return Service