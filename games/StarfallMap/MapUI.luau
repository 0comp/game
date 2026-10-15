local sectors=require(script.Parent.SectorCatalog)
local UI={}
local C=Color3.fromRGB
local bg=C(24,16,40)
local panel=C(44,30,64)
local muted=C(171,148,193)
local white=C(239,231,255)
local cyan=C(91,231,255)
local function make(class,parent,name,props)
 local o=Instance.new(class);o.Name=name
 for k,v in props or {} do o[k]=v end
 o.Parent=parent;return o
end
local function frame(parent,name,color)
 return make('Frame',parent,name,{BackgroundColor3=color or panel,BorderSizePixel=0})
end
local function corner(o,r) local c=o:FindFirstChildOfClass('UICorner') or make('UICorner',o,'Corner',{});c.CornerRadius=UDim.new(0,r or 12) end
local function stroke(o,c,t)
 return make('UIStroke',o,'Outline',{Color=c,Thickness=t or 1,Transparency=.35,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
local function label(parent,name,value,size,color,bold)
 return make('TextLabel',parent,name,{Text=value,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=size,TextColor3=color or white,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
end
local function rect(o,x,y,w,h) o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h) end
local function button(parent,name,value,color)
 local b=make('TextButton',parent,name,{Text=value,TextColor3=white,TextSize=14,Font=Enum.Font.FredokaOne,BorderSizePixel=0,BackgroundColor3=color or panel,AutoButtonColor=true});corner(b,9);return b
end
function UI.Build(parent)
 local old=parent:FindFirstChild('StarfallMapGui');if old then old:Destroy() end
 local gui=make('ScreenGui',parent,'StarfallMapGui',{ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=20,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local open=button(gui,'OpenChart','M  /  STAR CHART',panel);open.AnchorPoint=Vector2.new(0,1);open.Position=UDim2.new(0,20,1,-24);open.Size=UDim2.fromOffset(190,46);stroke(open,C(255,203,66),2)
 local window=frame(gui,'Window',bg);window.Position=UDim2.fromScale(.035,.045);window.Size=UDim2.fromScale(.93,.91);corner(window,18);stroke(window,C(66,94,128))
 local heading=label(window,'Heading','STAR CHART',26,C(255,207,81),true);heading.Font=Enum.Font.FredokaOne
 local subtitle=label(window,'Subtitle','STARFALL SALVAGERS  /  NAVIGATION NETWORK',10,muted,true)
 local close=button(window,'Close','CLOSE  ×',panel)
 local chart=frame(window,'Chart',C(23,10,35));corner(chart,14);chart.ClipsDescendants=true
 local gradient=make('UIGradient',chart,'Gradient',{Color=ColorSequence.new(C(33,15,54),C(13,8,26)),Rotation=35})
 local rand=Random.new(94)
 for i=1,70 do
  local star=frame(chart,'Star',i%4==0 and C(125,150,220) or white);star.Size=UDim2.fromOffset(i%7==0 and 3 or 1,i%7==0 and 3 or 1);star.Position=UDim2.fromScale(rand:NextNumber(),rand:NextNumber());star.BackgroundTransparency=rand:NextNumber(.25,.8);corner(star,9)
 end
 local orbitFrames={}
 for i=1,2 do local orbit=frame(chart,'Orbit',panel);orbit.BackgroundTransparency=1;corner(orbit,999);stroke(orbit,C(66,83,125));table.insert(orbitFrames,orbit) end
 local center=button(chart,'Station','HUB',C(33,62,83));center.TextColor3=cyan;center.TextSize=12;center.AnchorPoint=Vector2.new(.5,.5);center.Position=UDim2.fromScale(.5,.5);center.Size=UDim2.fromOffset(48,48);corner(center,999);stroke(center,cyan,2)
 local home=label(chart,'Home','SALVAGE STATION',10,cyan,true);home.AnchorPoint=Vector2.new(.5,0);home.Position=UDim2.new(.5,0,.5,29);home.Size=UDim2.fromOffset(140,20);home.TextXAlignment=Enum.TextXAlignment.Center
 local nodes={};local routes={};local lines={}
 for i,s in sectors do
  local route=frame(chart,'Route_'..s.Id,s.Color);route.BackgroundTransparency=.65;route.AnchorPoint=Vector2.new(.5,.5);table.insert(lines,{Object=route,Position=s.MapPosition});routes[s.Id]=route
  local n=button(chart,'Sector_'..s.Id,string.format('%02d',i),s.Color:Lerp(bg,.72));n.TextColor3=s.Color;n.AnchorPoint=Vector2.new(.5,.5);n.Position=UDim2.fromScale(s.MapPosition.X,s.MapPosition.Y);n.Size=UDim2.fromOffset(42,42);corner(n,999);local outline=stroke(n,s.Color,2)
  local title=label(chart,'Label_'..s.Id,s.Short,10,s.Color,true);title.AnchorPoint=Vector2.new(.5,0);title.Position=UDim2.new(s.MapPosition.X,0,s.MapPosition.Y,25);title.Size=UDim2.fromOffset(150,20);title.TextXAlignment=Enum.TextXAlignment.Center
  local status=label(chart,'Status_'..s.Id,s.Status=='AVAILABLE' and '● CHARTED' or '◇ UNKNOWN',9,muted);status.AnchorPoint=Vector2.new(.5,0);status.Position=UDim2.new(s.MapPosition.X,0,s.MapPosition.Y,44);status.Size=UDim2.fromOffset(120,16);status.TextXAlignment=Enum.TextXAlignment.Center
  nodes[s.Id]={Button=n,Title=title,Status=status,Outline=outline,Position=s.MapPosition}
 end
 local detail=make('ScrollingFrame',window,'Details',{BackgroundColor3=panel,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=cyan,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y});corner(detail,14);stroke(detail,C(43,64,91))
 local eyebrow=label(detail,'Eyebrow','SECTOR PROFILE',10,muted,true)
 local name=label(detail,'SectorName','',26,white,true);name.Font=Enum.Font.FredokaOne
 local desc=label(detail,'Description','',14,muted)
 local stat=label(detail,'Stats','',15,cyan,true)
 local lootHeading=label(detail,'LootHeading','POSSIBLE DISCOVERIES',10,muted,true)
 local loot=label(detail,'LootTheme','',16,white,true)
 local state=label(detail,'State','',11,cyan,true)
 local note=label(detail,'Note','Select any sector to inspect its route.',11,muted)
 local accent=frame(detail,'Accent',cyan);accent.Size=UDim2.new(1,0,0,3);corner(accent,12)
 local v={Gui=gui,Window=window,Nodes=nodes,SelectedId=nil,Connections={}}
 local function bind(signal,fn) table.insert(v.Connections,signal:Connect(fn)) end
 function v:Select(id)
  local selected=nil
  for _,s in sectors do if s.Id==id then selected=s;break end end
  if not selected then return false end
  self.SelectedId=id;detail.CanvasPosition=Vector2.zero;name.Text=selected.Name;desc.Text=selected.Description;stat.Text=selected.Distance..'   /   '..selected.Risk..' RISK';stat.TextColor3=selected.Color
  loot.Text=selected.Theme;state.Text=selected.Status=='AVAILABLE' and '●  ROUTE CHARTED' or '◇  AWAITING DEEP-SPACE SURVEY';state.TextColor3=selected.Color;accent.BackgroundColor3=selected.Color
  for key,n in nodes do local active=key==id;n.Outline.Thickness=active and 3 or 1;n.Outline.Transparency=active and 0 or .4;n.Button.BackgroundColor3=active and selected.Color:Lerp(bg,.35) or sectors[tonumber(n.Button.Text)].Color:Lerp(bg,.72);routes[key].BackgroundTransparency=active and .05 or .7 end
  return true
 end
 function v:SetOpen(value) window.Visible=value;open.Visible=not value end
 function v:Layout()
  local w,h=window.AbsoluteSize.X,window.AbsoluteSize.Y
  local portrait=w<650 and h>w*.85
  rect(heading,20,14,math.max(120,w-150),34);heading.TextSize=portrait and 22 or 26
  rect(subtitle,20,49,w-40,20);rect(close,w-115,17,95,34)
  local cw,ch
  if portrait then
   cw=w-28;ch=math.max(100,(h-94)*.5);rect(chart,14,80,cw,ch);rect(detail,14,88+ch,cw,math.max(64,h-ch-102))
  else local detailWidth=math.min(304,w*.44);cw=w-detailWidth-46;ch=h-98;rect(chart,16,80,cw,ch);rect(detail,w-detailWidth-16,80,detailWidth,ch) end
  local dw,dh=detail.Size.X.Offset,detail.Size.Y.Offset
  local compact=portrait or dh<400
  rect(eyebrow,18,12,dw-36,18);rect(name,18,34,dw-36,compact and 32 or 65);name.TextSize=compact and 21 or 27
  rect(desc,18,compact and 72 or 103,dw-36,compact and 40 or 80);desc.TextSize=compact and 12 or 14
  rect(stat,18,compact and 116 or 193,dw-36,26);stat.TextSize=compact and 12 or 14
  rect(lootHeading,18,compact and 147 or 237,dw-36,18);rect(loot,18,compact and 167 or 263,dw-36,compact and 40 or 75);loot.TextSize=compact and 12 or 16
  rect(state,18,compact and 211 or 352,dw-36,24);rect(note,18,dh-42,dw-36,26);note.Visible=dh>420
  -- Short detail layouts use a compact horizontal profile, with every field retained.
  if portrait and dh<250 then
   rect(eyebrow,14,8,dw-28,14);rect(name,14,26,dw-28,28);rect(desc,14,57,dw-28,32);rect(stat,14,93,dw-28,20);rect(lootHeading,14,117,dw-28,16);rect(loot,14,136,dw-28,35);rect(state,14,174,dw-28,20)
  end
  desc.Visible=true
  if not portrait and dh<280 then
   rect(eyebrow,14,8,dw-28,14);rect(name,14,26,dw-28,28);desc.Visible=false;rect(stat,14,59,dw-28,20);rect(lootHeading,14,85,dw-28,16);rect(loot,14,105,dw-28,42);rect(state,14,155,dw-28,20)
  end
  for i,o in orbitFrames do o.AnchorPoint=Vector2.new(.5,.5);o.Position=UDim2.fromScale(.5,.5);o.Size=UDim2.fromOffset(cw*(i==1 and .44 or .89),ch*(i==1 and .42 or .8)) end
  for _,l in lines do local dx=(l.Position.X-.5)*cw;local dy=(l.Position.Y-.5)*ch;l.Object.Position=UDim2.fromOffset(cw*.5+dx*.5,ch*.5+dy*.5);l.Object.Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),2);l.Object.Rotation=math.deg(math.atan2(dy,dx)) end
  for _,n in nodes do
   local labelWidth=math.min(cw-6,cw<400 and 105 or 150)
   n.Title.TextSize=cw<400 and 8 or 10;n.Title.Size=UDim2.fromOffset(labelWidth,20);n.Title.Position=UDim2.fromOffset(math.clamp(n.Position.X*cw,labelWidth*.5+3,cw-labelWidth*.5-3),n.Position.Y*ch+25);n.Title.Visible=ch>=230
   n.Status.Visible=cw>=400 and ch>=280;n.Button.Size=UDim2.fromOffset(44,44)
  end
  home.Visible=ch>=170
  home.TextSize=cw<400 and 8 or 10;home.Size=UDim2.fromOffset(cw<400 and 110 or 140,20)
  open.Text=game:GetService('UserInputService').TouchEnabled and 'STAR CHART' or 'M  /  STAR CHART'
 end
 for _,s in sectors do bind(nodes[s.Id].Button.Activated,function() v:Select(s.Id) end) end
 bind(close.Activated,function() v:SetOpen(false) end);bind(open.Activated,function() v:SetOpen(true) end)
 bind(center.Activated,function() v:SetOpen(false) end)
 bind(window:GetPropertyChangedSignal('AbsoluteSize'),function() v:Layout() end)
 v:Select(sectors[1].Id);v:SetOpen(false);task.defer(function() if gui.Parent then v:Layout() end end)
 bind(gui.Destroying,function() for _,c in v.Connections do c:Disconnect() end end)
 UI.Current=v;return v
end
return UI
