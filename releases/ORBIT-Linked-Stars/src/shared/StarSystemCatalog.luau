local U=require(script.Parent.StarUtil)
local S={Order={"Sun","Proxima","AlphaCentauriA","AlphaCentauriB"}}
local defs={
    Sun={Id="Sun",Name="Sun",Accent=Color3.fromRGB(172,242,111)},
    Proxima={Id="Proxima",Name="Proxima Centauri",Accent=Color3.fromRGB(255,132,102),
        Names={"Ember Haven","Ashmoon","Cinder","Twilight","Crimson Reach","Frostveil","Flarefall","Red Meridian","Glimmer","Nightglass","Corona","Far Lantern","Crown of Night"},
        Art={"Mars","Moon","Mars","Twilight","Gas","Ice","Sun","Gas","Ice","Void","Sun","Pulsar","Oblivion"}},
    AlphaCentauriA={Id="AlphaCentauriA",Name="Alpha Centauri A",Accent=Color3.fromRGB(255,213,126),
        Names={"Dawnshore","Pearlmoon","Azure","Goldhaven","Cloudsea","Halo","Solstice","Skygarden","Luminara","Highwater","Sunspire","Radiant Reach","Daybreak"},
        Art={"Earth","Moon","Earth","Gas","Gas","Ice","Sun","Earth","Ice","Earth","Sun","Pulsar","Gas"}},
    AlphaCentauriB={Id="AlphaCentauriB",Name="Alpha Centauri B",Accent=Color3.fromRGB(194,154,255),
        Names={"Amberfall","Basalt","Coppermoon","Saffron","Vesper","Violet Tide","Obsidian","Duskwind","Amethyst","Stormglass","Cinder Crown","Deep Lantern","Last Ember"},
        Art={"Mars","Moon","Mars","Gas","Gas","Ice","Void","Gas","Ice","Ice","Sun","Pulsar","Oblivion"}},
}
function S.Get(id) return defs[id] and U.Clone(defs[id]) or nil end
local function index(id) return table.find(S.Order,id) end
function S.Previous(id) local i=index(id);return i and S.Order[i-1] or nil end
function S.Next(id) local i=index(id);return i and S.Order[i+1] or nil end
function S.AreAdjacent(a,b)
    local x,y=index(a),index(b);return x~=nil and y~=nil and math.abs(x-y)==1
end
return S
