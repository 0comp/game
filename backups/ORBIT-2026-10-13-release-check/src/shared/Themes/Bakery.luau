-- A second theme using exactly the same server, UI and upgrade balance.
local function copy(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, item in pairs(value) do result[key] = copy(item) end
	return result
end
local Config = copy(require(script.Parent.Space))
local C = Color3.fromRGB
Config.GameTitle = "CRUMBLE"
Config.Tagline = "COOKIE CLICKER"
Config.DataStoreName = "CrumbleClicker_v1"
Config.Currency = {Name = "Cookies", ShortName = "CK"}
Config.Theme = {
	Background = C(29,18,25), Panel = C(47,29,38), PanelRaised = C(65,42,49),
	Accent = C(255,205,120), AccentAlt = C(238,159,182),
	Text = C(255,245,229), MutedText = C(187,158,160), Border = C(100,68,77),
	SkyTop = C(48,29,42), SkyBottom = C(78,41,47),
	TargetName = "Cookie", TargetImageId = "", ClickPrompt = "CLICK THE COOKIE", ShowOrbit = false,
	ClickHint = "A little dough goes a long way.", Mission = "BAKE YOUR WAY TO A COOKIE EMPIRE",
	WorldTitle = "GROW YOUR BAKERY", ShopSubtitle = "Fresh upgrades. More cookies.",
	ShopTip = "Hire a baker to keep producing between clicks.", AllWorldsText = "YOUR BAKERY EMPIRE IS COMPLETE",
	BurstName="SUGAR RUSH", CollectibleName="GOLDEN CRUMB", CollectorStyle="Cookie",
}
Config.UpgradePresentation = {
	TapCoil = {Name = "Better recipe", Description = "+1 cookie per click", Icon = "Bolt", Color = C(255,205,120)},
	MiniDrones = {Name = "Helpful baker", Description = "+1 cookie per second", Icon = "Drone", Color = C(238,159,182)},
	SolarArray = {Name = "Cookie oven", Description = "+8 cookies per second", Icon = "Solar", Color = C(255,178,109)},
	OrbitalFleet = {Name = "Cookie factory", Description = "+55 cookies per second", Icon = "Satellite", Color = C(184,160,255)},
	Reactor={Name="Mixing station",Description="+150 cookies per second",Icon="Solar",Color=C(255,200,109)},
	LunarMine={Name="Chocolate lab",Description="+1K cookies per second",Icon="Satellite",Color=C(199,207,230)},
	FusionLab={Name="Confectionery",Description="+6K cookies per second",Icon="Bolt",Color=C(255,145,113)},
	DysonArray={Name="Cookie city",Description="+40K cookies per second",Icon="Solar",Color=C(255,214,135)},
	StarForge={Name="Sugar foundry",Description="+250K cookies per second",Icon="Bolt",Color=C(255,170,111)},
	NebulaHarvester={Name="Dream bakery",Description="+1.5M cookies per second",Icon="Drone",Color=C(189,148,255)},
	QuantumGate={Name="Cookie portal",Description="+10M cookies per second",Icon="Satellite",Color=C(103,213,255)},
	UniverseEngine={Name="Infinite oven",Description="+60M cookies per second",Icon="Solar",Color=C(172,242,111)},
}
Config.Zones = {
	{Id="Home",Name="Home bakery",UnlockCost=0,Multiplier=1,Art="Cookie",Color=C(255,205,120)},
	{Id="Shop",Name="Cookie shop",UnlockCost=1200,Multiplier=2,Art="Cookie",Color=C(238,159,182)},
	{Id="Factory",Name="Factory",UnlockCost=40000,Multiplier=3,Art="Cookie",Color=C(255,178,109)},
	{Id="City",Name="Cookie city",UnlockCost=1200000,Multiplier=4,Art="Cookie",Color=C(249,199,141)},
	{Id="Kingdom",Name="Sugar kingdom",UnlockCost=35000000,Multiplier=5,Art="Cookie",Color=C(255,171,211)},
	{Id="Dream",Name="Dream bakery",UnlockCost=1000000000,Multiplier=6,Art="Cookie",Color=C(184,160,255)},
	{Id="Galaxy",Name="Cookie galaxy",UnlockCost=30000000000,Multiplier=8,Art="Cookie",Color=C(255,215,117)},
	{Id="Infinity",Name="Infinite bakery",UnlockCost=300000000000,Multiplier=10,Art="Cookie",Color=C(173,240,209)},
}
return Config
