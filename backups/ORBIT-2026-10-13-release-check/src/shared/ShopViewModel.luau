-- Stable shop ordering; cosmetic equip options point to pass ownership instead of creating duplicate offers.
local ViewModel = {}

local passOrder = { "DoubleProduction", "AutoTap", "SupporterOrbit", "NebulaPalette", "AuroraPalette" }
local productSections = {
	{ Key = "Energy", Title = "ENERGY", Description = "One-time spendable currency packs.", Order = { "SmallEnergy", "MediumEnergy", "LargeEnergy" } },
	{ Key = "Boosts", Title = "BOOSTS", Description = "Timed 2x production boosts stack with your burst.", Order = { "Boost15Minutes", "Boost30Minutes" } },
}
local cosmeticOrder = { "SupporterAura", "NebulaPalette", "AuroraPalette" }

local function offerEntry(key, offer)
	return {
		Key = key,
		Offer = offer,
		Id = offer.Id,
		Enabled = type(offer.Id) == "number" and offer.Id > 0 and offer.Id % 1 == 0,
		Name = offer.Name,
		Benefit = offer.Benefit,
		Kind = offer.Kind,
	}
end

function ViewModel.Build(catalog)
	local sections = {
		{ Key = "Passes", Title = "PERMANENT PASSES", Description = "Permanent upgrades that stay with your account.", Offers = {} },
		{ Key = "Energy", Title = productSections[1].Title, Description = productSections[1].Description, Offers = {} },
		{ Key = "Boosts", Title = productSections[2].Title, Description = productSections[2].Description, Offers = {} },
	}
	for _, key in ipairs(passOrder) do
		local offer = catalog.Passes[key]
		if offer then table.insert(sections[1].Offers, offerEntry(key, offer)) end
	end
	for sectionIndex, sectionDef in ipairs(productSections) do
		local section = sections[sectionIndex + 1]
		for _, key in ipairs(sectionDef.Order) do
			local offer = catalog.Products[key]
			if offer then table.insert(section.Offers, offerEntry(key, offer)) end
		end
	end

	local cosmetics = {}
	for _, key in ipairs(cosmeticOrder) do
		local cosmetic = catalog.Cosmetics[key]
		if cosmetic then
			table.insert(cosmetics, {
				Key = cosmetic.Key,
				Name = cosmetic.Name,
				PassKey = cosmetic.PassKey,
			})
		end
	end
	return { Sections = sections, Cosmetics = cosmetics }
end

return ViewModel