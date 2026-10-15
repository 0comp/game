-- Shared offer metadata for Creator Dashboard passes and developer products.
local Catalog = {}

Catalog.Passes = {
	DoubleProduction = {
		Key = "DoubleProduction", Kind = "Pass", Id = 2025543255, Category = "Passes",
		Name = "Double Production", Benefit = "Permanently doubles click and passive production.",
	},
	AutoTap = {
		Key = "AutoTap", Kind = "Pass", Id = 2028704251, Category = "Passes",
		Name = "Auto Tap", Benefit = "Adds ten server-authorized clicks per second.",
	},
	SupporterOrbit = {
		Key = "SupporterOrbit", Kind = "Pass", Id = 2025951241, Category = "Passes",
		Name = "Supporter Orbit", Benefit = "A permanent gold interface palette, nameplate accent, and click effect.",
	},
	NebulaPalette = {
		Key = "NebulaPalette", Kind = "Pass", Id = 2025585272, Category = "Passes",
		Name = "Nebula Palette", Benefit = "Unlocks the Nebula planet and interface palette.",
	},
	AuroraPalette = {
		Key = "AuroraPalette", Kind = "Pass", Id = 2026383217, Category = "Passes",
		Name = "Aurora Palette", Benefit = "Unlocks the Aurora planet and interface palette.",
	},
}

Catalog.Products = {
	SmallEnergy = {
		Key = "SmallEnergy", Kind = "Product", Id = 3718202097, Category = "Energy",
		Name = "Energy Cache", Benefit = "1,200 spendable Energy",
		Grant = { Type = "Currency", Amount = 1200 },
	},
	MediumEnergy = {
		Key = "MediumEnergy", Kind = "Product", Id = 3718202127, Category = "Energy",
		Name = "Energy Crate", Benefit = "40,000 spendable Energy",
		Grant = { Type = "Currency", Amount = 40000 },
	},
	LargeEnergy = {
		Key = "LargeEnergy", Kind = "Product", Id = 3718202156, Category = "Energy",
		Name = "Energy Vault", Benefit = "1,200,000 spendable Energy",
		Grant = { Type = "Currency", Amount = 1200000 },
	},
	Boost15Minutes = {
		Key = "Boost15Minutes", Kind = "Product", Id = 3718202184, Category = "Boosts",
		Name = "15-Minute Boost", Benefit = "2x production for 15 minutes",
		Grant = { Type = "PaidBoost", DurationSeconds = 900, Multiplier = 2 },
	},
	Boost30Minutes = {
		Key = "Boost30Minutes", Kind = "Product", Id = 3718202204, Category = "Boosts",
		Name = "30-Minute Boost", Benefit = "2x production for 30 minutes",
		Grant = { Type = "PaidBoost", DurationSeconds = 1800, Multiplier = 2 },
	},
}

Catalog.Cosmetics = {
	SupporterAura = { Key = "SupporterAura", Name = "Supporter Aura", PassKey = "SupporterOrbit" },
	NebulaPalette = { Key = "NebulaPalette", Name = "Nebula Palette", PassKey = "NebulaPalette" },
	AuroraPalette = { Key = "AuroraPalette", Name = "Aurora Palette", PassKey = "AuroraPalette" },
}

function Catalog.ResolveProduct(productId)
	if type(productId) ~= "number" or productId ~= productId or productId <= 0 or productId % 1 ~= 0 then
		return nil
	end
	for _, offer in pairs(Catalog.Products) do
		if offer.Id == productId then return offer end
	end
	return nil
end

return Catalog