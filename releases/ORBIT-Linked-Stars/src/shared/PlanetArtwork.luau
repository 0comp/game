-- Original, deterministic vector illustrations for ORBIT's 52 destinations.
-- Each entry has its own palette, surface recipe, landmark and seed.
local P={}
local function rgb(hex)return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))end
local definitions={}
local function system(prefix,rows)
    for i,row in ipairs(rows)do
        local id=prefix=="Sun" and row[1] or prefix.."_"..string.format("%02d",i)
        definitions[id]={Id=id,Name=row[1],Style=row[2],Top=rgb(row[3]),Bottom=rgb(row[4]),Land=rgb(row[5]),Light=rgb(row[6]),
            Feature=row[7],Seed=i*379+({Sun=17,Proxima=127,AlphaCentauriA=743,AlphaCentauriB=1637})[prefix]}
    end
end
system("Sun",{
    {"Earth","Coast","338DB9","102C59","6ACCA3","BCF6E7","Continents"},
    {"Moon","Crater","DCE0CE","5A647F","8D96A2","FFFFE9","ImpactBasin"},
    {"Mars","Canyon","E68B57","672D40","A34336","FFCE9C","PolarCap"},
    {"Jupiter","Bands","EBC392","80554D","BD795B","FFEDCF","GreatStorm"},
    {"Saturn","Bands","EED99E","817466","AC946C","FFF4CC","BroadRings"},
    {"Neptune","Cloud","4A94E4","202864","85D7E9","C8F8FF","BlueVortex"},
    {"Nova","Star","FFF0A8","D95143","FF9F46","FFFFDF","Eruption"},
    {"Singularity","Vortex","8155C3","100F2C","492D75","D5B6FF","FoldedSpace"},
    {"Aurora","Ice","88DBC8","294878","BDEEDB","A1FFD7","AuroraCurtain"},
    {"Helios","Star","FFD967","AF352E","FF9E35","FFFFC6","CoronaSpines"},
    {"Elysium","Garden","9B8BD8","3A2B66","4DDAAC","FFF0CD","FloatingGardens"},
    {"Pulsar","Star","C7FAFF","2353A0","6FC8F5","E8FFFF","PulsarBeams"},
    {"Oblivion","Void","39233F","070914","AD69C2","FFD19B","Accretion"},
})
system("Proxima",{
    {"Ember Haven","Lava","A6483B","261C36","462E3A","FFB073","ShieldVolcano"},
    {"Ashmoon","Crater","A9A3B7","3E354E","6D627F","F4C9AA","CraterChain"},
    {"Cinder","Canyon","CC6A43","452139","793138","FFC36F","BrokenCrust"},
    {"Twilight","Twilight","EF967B","221A49","6E3B78","FFD9A6","NightCities"},
    {"Crimson Reach","Bands","CC5B78","421E4D","843251","FFC7AB","DoubleStorm"},
    {"Frostveil","Ice","C1E1EB","344B75","74A5C7","F2FBFF","IceFissures"},
    {"Flarefall","Star","FFB66A","B53E4E","F37A44","FFF1C0","FallingFlares"},
    {"Red Meridian","Canyon","EBA078","60263F","B84F4E","FFD4B0","MeridianRidge"},
    {"Glimmer","Garden","4A7E8D","1C344C","64BDA5","CCFFE7","LuminousPools"},
    {"Nightglass","Crystal","64548A","15172C","312541","DCC8FF","ObsidianMirror"},
    {"Corona","Star","FFE2B5","C76C68","F79857","FFFFE7","DoubleCorona"},
    {"Far Lantern","Star","FFCA8E","6D365E","C8766A","FFF6C9","LanternBeam"},
    {"Crown of Night","Void","59415F","100F22","884F81","FFC49E","NightCrown"},
})
system("AlphaCentauriA",{
    {"Dawnshore","Coast","69C9D5","305C95","E1C68A","FFF1C7","DawnCoast"},
    {"Pearlmoon","Crater","F1E3DD","A195B7","C7B6C3","FFFAED","PearlBasin"},
    {"Azure","Coast","36B6E0","175A99","78D8BB","E4FBFF","CloudSpirals"},
    {"Goldhaven","Lava","E3B764","785846","AD7B46","FFF2B0","GoldVeins"},
    {"Cloudsea","Cloud","DFE5EE","7C92C6","B7BDE1","FFF9DD","CloudIslands"},
    {"Halo","Ice","D8E9EC","658FB7","A9C9D9","FFF1C0","HaloRings"},
    {"Solstice","Twilight","F5CC88","5478A1","D6DFCA","FFF3CF","SeasonDivide"},
    {"Skygarden","Garden","6EAFBA","3C6287","AEDB87","F6FFD3","SkyIslands"},
    {"Luminara","Garden","609EAB","27466A","88C6AB","EDFFB8","LightNetwork"},
    {"Highwater","Cloud","5CA7D5","204B7C","9DD7E8","E6FFFF","ThreeTyphoons"},
    {"Sunspire","Crystal","ECCB7F","887062","C69B61","FFFFCF","CrystalSpire"},
    {"Radiant Reach","Star","FFF1BD","C98657","FFC76F","FFFFFF","RadiantBeams"},
    {"Daybreak","Twilight","FFD6A6","8876AA","D59FA0","FFFFE6","SunriseArc"},
})
system("AlphaCentauriB",{
    {"Amberfall","Bands","E6AA5F","6C3C5B","BC6A58","FFDA94","AmberFalls"},
    {"Basalt","Crystal","6B6B82","252A42","404356","D7B4FF","BasaltColumns"},
    {"Coppermoon","Crater","C7A075","685B74","8CA49E","F8D2A3","CopperRays"},
    {"Saffron","Dunes","DAB958","76604D","A3844D","FFF0AD","SaffronDunes"},
    {"Vesper","Twilight","D89AAE","36325E","87648D","FFD9B9","EveningArc"},
    {"Violet Tide","Coast","8E83CB","393D78","C3A2D3","F2DAFF","TidalLagoons"},
    {"Obsidian","Crystal","4B526F","111C34","292C47","BEA7FF","MirrorScar"},
    {"Duskwind","Cloud","A28DC9","473C73","77729E","EACDFF","WindRibbons"},
    {"Amethyst","Crystal","BA8BCF","473067","8B4FAD","FFE6FF","GemFacets"},
    {"Stormglass","Lava","71859A","283349","3D4B64","B8E8FF","Lightning"},
    {"Cinder Crown","Lava","D77B64","4B2B45","7C3F51","FFC89A","FireCrown"},
    {"Deep Lantern","Star","8498D2","272A60","A578CE","DFD4FF","DeepBeams"},
    {"Last Ember","Void","674150","141A2F","8E4D55","FFB88A","LastLight"},
})
function P.Get(id)local d=definitions[id];return d and table.clone(d) or nil end
function P.Draw(art,zone,thumbnail)
    local d=definitions[zone.Id];if not d then return false end
    art:SetAttribute("OriginalDesignId",d.Id);art:SetAttribute("DesignFeature",d.Feature)
    local random=Random.new(d.Seed)
    local function make(class,parent,name,props)
        local o=Instance.new(class);o.Name=name;for k,v in pairs(props)do o[k]=v end;o.Parent=parent;return o
    end
    local function ellipse(name,x,y,w,h,color,alpha,parent)
        local o=make("Frame",parent or art,name,{BorderSizePixel=0,BackgroundColor3=color,BackgroundTransparency=alpha or 0,
            Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h)})
        make("UICorner",o,"Round",{CornerRadius=UDim.new(1,0)});return o
    end
    local function outline(o,color,alpha,width)
        return make("UIStroke",o,"Outline",{Color=color,Transparency=alpha or 0,Thickness=width or 2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    end
    local function gradient(o,a,b,rotation)
        o.BackgroundColor3=Color3.new(1,1,1)
        return make("UIGradient",o,"Gradient",{Color=ColorSequence.new(a,b),Rotation=rotation or 0})
    end
    local function ring(name,x,y,w,h,color,width,rotation,alpha)
        local o=ellipse(name,x,y,w,h,color,1);outline(o,color,alpha or .1,width or 2);o.Rotation=rotation or 0;return o
    end
    -- Surface spans are clipped mathematically to the circular silhouette.
    local function span(name,y,left,right,height,color,alpha)
        local edge=math.sqrt(math.max(0,145^2-(y+height/2-150)^2))
        left=math.max(left,150-edge);right=math.min(right,150+edge)
        if right>left then return ellipse(name,left,y,right-left,height,color,alpha)end
    end
    local function polygon(name,points,color,alpha)
        local low,high=300,0;for _,p in ipairs(points)do low=math.min(low,p[2]);high=math.max(high,p[2])end
        local step=thumbnail and 10 or 3
        for y=math.max(8,low),math.min(290,high),step do
            local xs={};for i,a in ipairs(points)do local b=points[i%#points+1]
                if(a[2]<=y and b[2]>y)or(b[2]<=y and a[2]>y)then table.insert(xs,a[1]+(y-a[2])/(b[2]-a[2])*(b[1]-a[1]))end
            end;table.sort(xs)
            for i=1,#xs-1,2 do
                local surface=span(name,y,xs[i],xs[i+1],step+.5,color,alpha)
                if surface then surface:SetAttribute("CosmeticSurface",true)end
            end
        end
    end
    local function line(name,x1,y1,x2,y2,color,width)
        local distance=Vector2.new(x2-x1,y2-y1).Magnitude
        local steps=math.max(1,math.ceil(distance/(thumbnail and 12 or math.max(1.5,width*.65))))
        for i=0,steps do local t=i/steps;local x,y=x1+(x2-x1)*t,y1+(y2-y1)*t
            if(x-150)^2+(y-150)^2<(142-width)^2 then ellipse(name,x-width/2,y-width/2,width,width,color)end
        end
    end
    local function crack(name,color,vertical)
        local x,y=vertical and random:NextNumber(90,190)or 36,vertical and 26 or random:NextNumber(90,180)
        for i=1,6 do local nx=vertical and x+random:NextNumber(-27,27)or x+37;local ny=vertical and y+38 or y+random:NextNumber(-22,22)
            line(name,x,y,nx,ny,color,4);x,y=nx,ny
        end
    end
    local atmosphere=ellipse("Atmosphere",-7,-7,314,314,d.Light,1);outline(atmosphere,d.Light,.76,6)
    local globe=ellipse("Globe",0,0,300,300,d.Top);gradient(globe,d.Top,d.Bottom,d.Style=="Twilight" and 0 or 35)
    outline(globe,d.Light,.4,2)
    if d.Style=="Coast" or d.Style=="Garden" then
        local count=d.Style=="Garden"and 7 or 4
        for i=1,count do
            local angle=random:NextNumber(0,math.pi*2);local radius=random:NextNumber(30,91)
            local cx,cy=150+math.cos(angle)*radius,150+math.sin(angle)*radius
            local points={};for j=0,8 do local a=j/9*math.pi*2;local r=random:NextNumber(17,42)
                table.insert(points,{cx+math.cos(a)*r,cy+math.sin(a)*r*.75})end
            polygon("Island"..i,points,d.Land)
            if d.Style=="Garden"then ellipse("GardenGlow",cx-4,cy-3,8,6,d.Light,.16)end
        end
        for i=1,5 do local y=random:NextNumber(40,245);span("Cloud",y,random:NextNumber(30,130),random:NextNumber(160,270),4,d.Light,.63)end
    elseif d.Style=="Crater" then
        for i=1,9 do local a=random:NextNumber(0,6.28);local radius=random:NextNumber(20,112);local size=random:NextNumber(17,46)
            local x,y=150+math.cos(a)*radius-size/2,150+math.sin(a)*radius-size/2
            local crater=ellipse("Impact"..i,x,y,size,size*.78,d.Land,.15);outline(crater,d.Light,.66,2)
            ellipse("ImpactShadow",x+4,y+5,size*.65,size*.42,d.Bottom,.35)
        end
    elseif d.Style=="Canyon" or d.Style=="Lava" then
        for i=1,3 do crack("Fault",d.Style=="Lava"and d.Light or d.Bottom,i%2==0)end
        for i=1,5 do local x,y=random:NextNumber(65,225),random:NextNumber(65,225)
            polygon("Plate"..i,{{x-25,y},{x-7,y-17},{x+25,y-9},{x+18,y+22},{x-19,y+15}},d.Land,.23)
        end
    elseif d.Style=="Bands" or d.Style=="Cloud" or d.Style=="Dunes" then
        local frequency=random:NextNumber(.025,.055);local phase=random:NextNumber(0,6.28)
        for y=24,274,13 do local h=d.Style=="Cloud"and 12 or 7
            local wave=math.sin(y*frequency+phase)*25
            span(d.Style=="Cloud"and"Cloud"or"Ribbon",y,18+wave,282-wave,h,(math.floor(y/13)%2==0)and d.Land or d.Light,d.Style=="Dunes"and .38 or .56)
        end
    elseif d.Style=="Ice" then
        for i=1,5 do local x,y=random:NextNumber(55,240),random:NextNumber(45,230)
            polygon("Glacier"..i,{{x-30,y+20},{x-14,y-20},{x+12,y-32},{x+34,y+8},{x+5,y+35}},d.Land,.18)
        end
        crack("GlacialRift",d.Bottom,true)
    elseif d.Style=="Twilight" then
        polygon("TwilightHighlands",{{14,180},{55,156},{92,181},{128,144},{164,169},{201,145},{267,179},{285,225},{20,244}},d.Land)
        polygon("NightRidge",{{42,237},{89,197},{137,225},{179,188},{238,215},{262,256},{156,292},{65,267}},d.Bottom,.2)
        for i=1,7 do local x,y=145+math.sin(i*1.8+d.Seed)*16,36+i*29;ellipse("DuskLight",x,y,5,5,d.Light,.1)end
    elseif d.Style=="Crystal" then
        local cx,cy=random:NextNumber(121,173),random:NextNumber(121,173)
        for i=1,7 do local a=i/7*6.28+random:NextNumber(-.2,.2);local radius=random:NextNumber(56,99)
            local x,y=150+math.cos(a)*radius,150+math.sin(a)*radius
            polygon("Facet"..i,{{cx,cy},{x-25,y-25},{x+29,y-13},{x+12,y+30}},i%2==0 and d.Land or d.Top,.18)
            line("FacetEdge",cx,cy,x,y,d.Light,2)
        end
    elseif d.Style=="Vortex" then
        for i=1,7 do local size=35+i*29;ring("Warp"..i,150-size/2,150-size/3,size,size*.66,d.Land,3,i*17,.2)end
        ellipse("WarpEye",129,129,42,42,d.Bottom)
    elseif d.Style=="Star" then
        for i=1,8 do local a=i/8*6.28+random:NextNumber(-.2,.2);local radius=random:NextNumber(43,105)
            local x,y=150+math.cos(a)*radius,150+math.sin(a)*radius;local width=random:NextNumber(22,48)
            ellipse("Convection"..i,x-width/2,y-12,width,random:NextNumber(13,30),d.Land,.48)
        end
        ring("Photosphere",15,15,270,270,d.Light,3,0,.38)
        ellipse("StellarHeart",114,114,72,72,d.Light,.18)
    elseif d.Style=="Void" then
        ellipse("EventHorizon",34,34,232,232,d.Bottom)
        ring("HorizonRim",32,32,236,236,d.Land,4,0,.25)
    end
    -- Individual landmarks distinguish worlds even within the same surface family.
    local f=d.Feature
    if f=="BroadRings" or f=="HaloRings" then
        local rotation=f=="BroadRings"and -19 or 34
        for i=1,f=="BroadRings"and 4 or 2 do ring("PlanetRing",-40-i*5,104-i*3,380+i*10,84+i*6,d.Light,2+i,rotation,.18+i*.1)end
    elseif f=="GreatStorm" or f=="DoubleStorm" or f=="BlueVortex" or f=="ThreeTyphoons" then
        local count=f=="ThreeTyphoons"and 3 or f=="DoubleStorm"and 2 or 1
        for i=1,count do local x,y=88+i*28,122+i*23
            for j=1,3 do ring("StormEye",x-j*9,y-j*4,22+j*18,12+j*8,d.Light,2,-15-i*12,.25+j*.1)end
        end
    elseif f=="PulsarBeams" or f=="LanternBeam" or f=="RadiantBeams" or f=="DeepBeams" then
        local rig=make("Frame",art,"PulseBeams",{BackgroundTransparency=1,Size=UDim2.fromOffset(300,300),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Rotation=d.Seed%65})
        local glow=ellipse("JetGlow",136,-36,28,372,d.Light,.48,rig)
        ellipse("JetCore",146,-43,8,386,d.Light,.08,rig)
        if f=="DeepBeams"or f=="RadiantBeams"then
            local cross=ellipse("CrossBeam",15,147,270,6,d.Land,.2,rig);cross.Rotation=25
        end
        ring("PulseRing",-12,-12,324,324,d.Light,3,0,.4)
    elseif f=="Accretion" or f=="FoldedSpace" or f=="LastLight" then
        local angle=f=="LastLight"and 24 or -24
        ring("AccretionRing",-39,104,378,92,d.Light,f=="LastLight"and 4 or 8,angle,.1)
        ring("InnerAccretion",-18,110,336,80,d.Land,3,angle,.18)
        if f=="LastLight"then ellipse("LastEmber",113,135,26,17,d.Light,.1)end
    elseif f=="AuroraCurtain" then
        for i=1,6 do local y=32+i*10;span("AuroraCurtain",y,45+i*5,257-i*5,4,d.Light,.25+i*.07)end
    elseif f=="CoronaSpines" or f=="FireCrown" or f=="NightCrown" or f=="DoubleCorona" then
        ring("CrownHalo",-16,-16,332,332,d.Light,3,d.Seed%40,.3)
        if f=="DoubleCorona"then ring("OuterCorona",-29,-29,358,358,d.Land,5,0,.5)end
        for i=1,9 do local a=i/9*6.28;local x,y=150+math.cos(a)*139,150+math.sin(a)*139
            local flare=ellipse("CrownTip",x-5,y-12,10,24,d.Light,.24);flare.Rotation=math.deg(a)-90
        end
    elseif f=="ShieldVolcano" or f=="ImpactBasin" or f=="PearlBasin" or f=="ObsidianMirror" then
        local x,y=f=="ShieldVolcano"and 85 or 170,f=="PearlBasin"and 80 or 122
        for i=1,3 do ring("LandmarkBasin",x-i*10,y-i*7,30+i*20,22+i*14,d.Light,2,17,.35+i*.1)end
        if f=="ShieldVolcano"then ellipse("LavaLake",x,y,28,17,d.Light,.1)end
    elseif f=="PolarCap" or f=="SeasonDivide" then
        polygon("PolarCap",{{77,26},{123,8},{180,13},{222,39},{188,58},{133,46},{102,57}},d.Light,.15)
    elseif f=="CraterChain" then
        for i=1,6 do ring("ImpactChain",65+i*22,40+i*27,15+i*2,12+i*2,d.Light,2,-18,.32)end
    elseif f=="FloatingGardens" or f=="SkyIslands" or f=="CloudIslands" then
        for i=1,4 do local x,y=50+i*39,50+(i%3)*58
            ellipse("IslandShadow",x-2,y+14,40,10,d.Bottom,.38)
            polygon("FloatingIsland",{{x,y},{x+31,y-8},{x+42,y+9},{x+21,y+22}},d.Light,.15)
        end
    elseif f=="LuminousPools" or f=="LightNetwork" or f=="TidalLagoons" then
        for i=1,6 do local x,y=75+(i%3)*57,70+math.floor(i/3)*70
            ring("LuminousLagoon",x,y,20+i*3,13+i*2,d.Light,3,i*23,.12)
        end
    elseif f=="CrystalSpire" or f=="BasaltColumns" or f=="GemFacets" then
        for i=1,5 do local x=68+i*27+random:NextNumber(-6,6);local height=random:NextNumber(31,91)
            polygon("CrystalTower",{{x,190},{x+8,190-height},{x+20,181-height},{x+23,190},{x+11,204}},i%2==0 and d.Light or d.Land,.05)
        end
    elseif f=="DawnCoast" or f=="SunriseArc" or f=="EveningArc" then
        ring("DawnArc",27,23,246,250,d.Light,4,f=="EveningArc"and -35 or 17,.35)
        ellipse("HorizonSun",50,90,22,22,d.Light,.08)
    elseif f=="Eruption" or f=="FallingFlares" then
        for i=1,5 do local x,y=65+i*31+random:NextNumber(-13,13),random:NextNumber(55,185)
            local flare=ellipse("SolarEruption",x,y,11,45,d.Light,.22);flare.Rotation=-30+i*7
        end
    elseif f=="MeridianRidge" or f=="AmberFalls" then
        for i=1,3 do local x=110+i*23;line("Meridian",x,37,x-17,260,d.Light,3)end
    elseif f=="CloudSpirals" or f=="WindRibbons" then
        for i=1,4 do ring("CloudSpiral",60+i*18,50+i*39,90,18,d.Light,3,-20+i*9,.4)end
    elseif f=="CopperRays" then
        for i=1,6 do local a=i/6*6.28;line("ImpactRay",137,127,137+math.cos(a)*76,127+math.sin(a)*76,d.Land,3)end
    elseif f=="MirrorScar" then
        polygon("MirrorFace",{{80,64},{186,38},{235,125},{191,221},{116,257},{59,159}},d.Land,.22)
        line("SilverScar",95,64,198,233,d.Light,4)
    elseif f=="SaffronDunes" then
        for i=1,5 do local y=60+i*32;span("DuneCrest",y,45+i*5,260-i*8,3,d.Light,.24)end
    elseif f=="GoldVeins" or f=="IceFissures" or f=="BrokenCrust" or f=="Lightning" then
        crack(f,d.Light,true);if f=="Lightning"then crack("StormFork",d.Light,false)end
    end
    local shade=ellipse("NightSide",0,0,300,300,Color3.fromRGB(9,12,30))
    local g=gradient(shade,Color3.fromRGB(9,12,30),Color3.fromRGB(9,12,30),8)
    g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.55,.96),NumberSequenceKeypoint.new(1,.38)})
    return true
end
return P
