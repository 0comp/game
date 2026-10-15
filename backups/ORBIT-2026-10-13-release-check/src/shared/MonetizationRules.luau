-- Pure, server-side monetization rules shared with the Studio test harness.
local Rules = {}
Rules.AutoTapInterval = 0.1

local function finite(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function clone(value, seen)
	if type(value) ~= "table" then return value end
	seen = seen or {}
	if seen[value] then return seen[value] end
	local result = {}
	seen[value] = result
	for key, child in pairs(value) do
		result[clone(key, seen)] = clone(child, seen)
	end
	return result
end

local function validProduct(offer)
	return type(offer) == "table"
		and offer.Kind == "Product"
		and finite(offer.Id)
		and offer.Id > 0
		and offer.Id % 1 == 0
		and type(offer.Grant) == "table"
end

function Rules.ExtendBoost(currentEnd, duration, now)
	currentEnd = finite(currentEnd) and math.max(0, currentEnd) or 0
	duration = finite(duration) and math.max(0, duration) or 0
	now = finite(now) and math.max(0, now) or 0
	return math.max(currentEnd, now) + duration
end

function Rules.ApplyProduct(profile, offer, purchaseId, now, maxCurrency)
	local result = clone(profile)
	if type(result) ~= "table" then result = {} end
	if type(result.ProcessedReceipts) ~= "table" then result.ProcessedReceipts = {} end
	local invalid = { Status = "Invalid", PurchaseId = purchaseId }
	if type(purchaseId) ~= "string" or purchaseId == "" or #purchaseId > 128
		or not finite(now) or not validProduct(offer) then
		return result, invalid
	end

	local previous = result.ProcessedReceipts[purchaseId]
	if previous then
		if type(previous) ~= "table" or (previous.ProductId ~= nil and previous.ProductId ~= offer.Id) then
			return result, invalid
		end
		return result, { Status = "Duplicate", PurchaseId = purchaseId, ProductId = offer.Id, Effect = clone(previous.Effect) }
	end

	local grant = offer.Grant
	local effect
	if grant.Type == "Currency" then
		if result.Currency == nil then result.Currency = 0 end
		if not finite(grant.Amount) or grant.Amount <= 0 or not finite(result.Currency) then
			return result, invalid
		end
		maxCurrency = finite(maxCurrency) and math.max(0, maxCurrency) or 1e18
		if grant.Amount > maxCurrency - result.Currency then
			return result, { Status = "Deferred", PurchaseId = purchaseId }
		end
		result.Currency += grant.Amount
		effect = { Type = "Currency", Amount = grant.Amount }
	elseif grant.Type == "PaidBoost" then
		if not finite(grant.DurationSeconds) or grant.DurationSeconds <= 0
			or not finite(grant.Multiplier) or grant.Multiplier <= 1 then
			return result, invalid
		end
		local endsAt = Rules.ExtendBoost(result.PaidBoostEndsAt, grant.DurationSeconds, now)
		result.PaidBoostEndsAt = endsAt
		effect = { Type = "PaidBoost", EndsAt = endsAt }
	else
		return result, invalid
	end

	local receipt = { Status = "Granted", PurchaseId = purchaseId, ProductId = offer.Id, Effect = effect }
	result.ProcessedReceipts[purchaseId] = clone(receipt)
	return result, receipt
end

function Rules.ReconcileReceipt(profile, receipt)
	local result = clone(profile)
	if type(result) ~= "table" then result = {} end
	if type(result.ProcessedReceipts) ~= "table" then result.ProcessedReceipts = {} end
	if type(receipt) ~= "table" or receipt.Status ~= "Granted"
		or type(receipt.PurchaseId) ~= "string" or receipt.PurchaseId == ""
		or type(receipt.Effect) ~= "table" then
		return result
	end
	if result.ProcessedReceipts[receipt.PurchaseId] then return result end

	local effect = receipt.Effect
	if effect.Type == "Currency" and finite(effect.Amount) and effect.Amount > 0
		and finite(result.Currency) then
		result.Currency += effect.Amount
	elseif effect.Type == "PaidBoost" and finite(effect.EndsAt) and effect.EndsAt > 0 then
		result.PaidBoostEndsAt = math.max(finite(result.PaidBoostEndsAt) and result.PaidBoostEndsAt or 0, effect.EndsAt)
	else
		return result
	end
	result.ProcessedReceipts[receipt.PurchaseId] = clone(receipt)
	return result
end

function Rules.ResolvePassOwnership(marketplace, userId, passes, onlyKey, skipKey)
	local owned, unknown = {}, false
	if type(passes) ~= "table" then return owned, true end

	for key, offer in pairs(passes) do
		if (onlyKey == nil or key == onlyKey) and (skipKey == nil or key ~= skipKey) then
			if type(offer) == "table" and finite(offer.Id) and offer.Id > 0 and offer.Id % 1 == 0 then
				local ok, value = pcall(function()
					return marketplace:UserOwnsGamePassAsync(userId, offer.Id)
				end)
				if ok then
					owned[key] = value == true
				else
					unknown = true
				end
			else
				owned[key] = false
			end
		end
	end

	return owned, unknown
end

function Rules.CanEquipCosmetic(key, cosmetics, ownedPasses)
	local cosmetic = type(cosmetics) == "table" and cosmetics[key]
	return type(cosmetic) == "table"
		and type(ownedPasses) == "table"
		and ownedPasses[cosmetic.PassKey] == true
end

function Rules.AdvanceAutoTap(ownedPasses, accumulated, elapsed)
	if type(ownedPasses) ~= "table" or ownedPasses.AutoTap ~= true then return 0, 0 end
	accumulated = finite(accumulated) and math.clamp(accumulated, 0, 0.999999) or 0
	elapsed = finite(elapsed) and math.clamp(elapsed, 0, 1) or 0
	local total = accumulated + elapsed * 10
	local clicks = math.floor(total + 1e-8)
	return clicks, math.max(0, total - clicks)
end

function Rules.ClickFeedback(gain)
	if not finite(gain) or gain <= 0 then return nil end
	return { Kind = "ClickFeedback", Gain = gain }
end

function Rules.DeveloperProductAvailability(profileWritable, receiptLedgerBytes)
	if profileWritable ~= true then return false, "PersistenceUnavailable" end
	if not finite(receiptLedgerBytes) or receiptLedgerBytes >= 3_500_000 then return false, "StorageLimit" end
	return true, nil
end

function Rules.OfferState(offer, hasPrice, owned, active, canFit, canTransact, unavailableReason)
	if type(offer) ~= "table" then return { Status = "Unavailable", CanPrompt = false } end
	if offer.Kind == "Pass" and owned then return { Status = "Owned", CanPrompt = false } end
	if type(offer.Id) ~= "number" or offer.Id <= 0 or offer.Id % 1 ~= 0 or not hasPrice then
		return { Status = "Unavailable", CanPrompt = false }
	end
	if offer.Kind == "Product" and canTransact == false then
		local reason = unavailableReason == "PersistenceUnavailable" and "PersistenceUnavailable" or "StorageLimit"
		return { Status = reason, CanPrompt = false }
	end
	if offer.Kind == "Product" and offer.Grant and offer.Grant.Type == "Currency" and not canFit then
		return { Status = "WalletFull", CanPrompt = false }
	end
	if offer.Kind == "Product" and offer.Grant and offer.Grant.Type == "PaidBoost" and active then
		return { Status = "Active", CanPrompt = true }
	end
	return { Status = "Available", CanPrompt = true }
end

return Rules