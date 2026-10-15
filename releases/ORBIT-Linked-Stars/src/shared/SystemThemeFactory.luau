local Base=require(script.Parent.Themes.Space)
local Stars=require(script.Parent.StarSystemCatalog)
local U=require(script.Parent.StarUtil)
local PlanetArtwork=require(script.Parent.PlanetArtwork)
local F={}
local function originalPlanets(config)
    for _,zone in ipairs(config.Zones)do
        local design=PlanetArtwork.Get(zone.Id)
        if design then zone.Art="Original";zone.Color=design.Light;zone.ImageId=nil end
    end
    return config
end
-- Presentation only: economy/save IDs remain the same in every system.
local producerIds={"TapCoil","MiniDrones","SolarArray","OrbitalFleet","Reactor","LunarMine","FusionLab","DysonArray","SunPrism","StarForge","NebulaHarvester","QuantumGate","CausalityTap","UniverseEngine","AuroraCollector","HeliosCore","ElysiumSpire","PulsarArray","OblivionEngine"}
local producerNames={
    Proxima={"Ember striker","Cinder scout","Flare sail","Twilight fleet","Magma reactor","Ash extractor","Corona laboratory","Red-dwarf lattice","Flare crystal","Ember crucible","Dust siphon","Twilight portal","Redshift pulse","Nightfall engine","Flare catcher","Crimson heart","Dusk observatory","Beacon swarm","Eclipse furnace"},
    AlphaCentauriA={"Photon lens","Dawn glider","Radiant petals","Helios flotilla","Sunlight turbine","Pearl excavator","Prism laboratory","Daylight canopy","Spectrum prism","Auric foundry","Light harvester","Halo gateway","Photon cascade","Daybreak engine","Aurora sail","Radiant core","Sunspire tower","Lighthouse array","Horizon drive"},
    AlphaCentauriB={"Plasma needle","Vesper seeker","Amber vanes","Dusk squadron","Violet reactor","Basalt drill","Ion laboratory","Eclipse lattice","Amethyst shard","Plasma forge","Storm siphon","Violet aperture","Echo pulse","Dusk dynamo","Ion net","Amber nucleus","Obsidian spire","Storm relay","Last-ember engine"},
}
local researchIds={"AutoBuy","Focus","Efficiency","Discount","Logistics","Capacity","Storage"}
local permanentIds={"Mastery","Touch","Automation","Cargo","Power","Clock"}
local researchNames={
    Proxima={"Ember Auto Buy","Flare targeting","Thermal recovery","Salvage contracts","Cinder routes","Corona reservoir","Nightfall reserves"},
    AlphaCentauriA={"Photon Auto Buy","Lens alignment","Radiant efficiency","Solar contracts","Sunlane logistics","Daylight reservoir","Luminous reserves"},
    AlphaCentauriB={"Vesper Auto Buy","Plasma focusing","Ion recycling","Basalt contracts","Twilight routes","Storm reservoir","Eclipse reserves"},
}
local permanentNames={
    Proxima={"Ember legacy","Crimson touch","Cinder automata","Ashen treasure","Undying flare","Nightfall chronicle"},
    AlphaCentauriA={"Radiant legacy","Photon touch","Dawn automata","Golden cargo","Eternal sunlight","Daybreak chronicle"},
    AlphaCentauriB={"Vesper legacy","Plasma touch","Dusk automata","Obsidian cargo","Lasting storm","Eclipse chronicle"},
}
local stellarIds={"SignalAmplifier","SupplyNetwork","StellarLegacy","VoyagerStorage"}
local stellarNames={
    Proxima={"Redshift transmitter","Cinder supply web","Crimson inheritance","Nightfall vault"},
    AlphaCentauriA={"Photon transmitter","Sunlane network","Radiant inheritance","Daybreak vault"},
    AlphaCentauriB={"Echo transmitter","Vesper supply web","Violet inheritance","Eclipse vault"},
}
local colors={Color3.fromRGB(255,148,105),Color3.fromRGB(192,190,211),Color3.fromRGB(234,130,100),Color3.fromRGB(107,196,231),Color3.fromRGB(231,182,128),Color3.fromRGB(133,190,244),Color3.fromRGB(255,205,117),Color3.fromRGB(183,145,240),Color3.fromRGB(125,235,211),Color3.fromRGB(142,138,225),Color3.fromRGB(255,188,117),Color3.fromRGB(133,232,255),Color3.fromRGB(230,154,231)}
function F.Get(id)
    local star=Stars.Get(id);assert(star,"Unknown star system")
    local c=U.Clone(Base);c.SystemId=id;c.SystemName=star.Name
    if id=="Sun" then return originalPlanets(c) end
    c.Theme.Accent=star.Accent
    c.Theme.AccentAlt=star.Accent:Lerp(Color3.fromRGB(129,164,255),.5)
    c.Theme.SkyTop=star.Accent:Lerp(Color3.fromRGB(6,10,26),.92)
    c.Theme.SkyBottom=star.Accent:Lerp(Color3.fromRGB(10,12,30),.84)
    c.Theme.Mission="BUILD A NEW ENERGY EMPIRE"
    c.Theme.AllWorldsText=Stars.Next(id) and "READY TO DISCOVER THE NEXT STAR" or "ALL STAR SYSTEMS DISCOVERED"
    for i,z in ipairs(c.Zones)do
        z.Id=id.."_"..string.format("%02d",i);z.Name=star.Names[i]
        z.Subtitle="A new frontier around "..star.Name
        z.Art=star.Art[i];z.Color=colors[i]:Lerp(star.Accent,.28)
        z.Rings=(i==5 or i==8 or i==13) and z.Art=="Gas"
        z.ImageId=nil
    end
    c.Theme.TargetName=c.Zones[1].Name
    for i,key in ipairs(producerIds)do
        local p=c.UpgradePresentation[key]
        p.Name=producerNames[id][i];p.Icon=id..":"..i
        p.Color=star.Accent:Lerp(colors[(i-1)%#colors+1],.35);p.ImageId=nil
    end
    for _,entry in ipairs({{"ResearchPresentation",researchIds,researchNames[id],19},
        {"PermanentPresentation",permanentIds,permanentNames[id],26},{"StellarPresentation",stellarIds,stellarNames[id],32}})do
        c[entry[1]]={}
        for i,key in ipairs(entry[2])do c[entry[1]][key]={Name=entry[3][i],Icon=id..":"..(entry[4]+i),Color=star.Accent}end
    end
    return originalPlanets(c)
end
return F
