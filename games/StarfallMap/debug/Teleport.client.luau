-- STUDIO DEBUG ONLY. No interface is created in a published server.
local RunService=game:GetService('RunService')
if not RunService:IsStudio()then return end

local Players=game:GetService('Players')
local player=Players.LocalPlayer
local remote=game:GetService('ReplicatedStorage'):WaitForChild('StarfallStudioDebugTeleport',15)
if not remote then return end
local gui=Instance.new('ScreenGui');gui.Name='StarfallStudioDebugTeleports'
gui.ResetOnSpawn=false;gui.DisplayOrder=80;gui.Parent=player:WaitForChild('PlayerGui')
local function label(parent,name,text,size,pos,color)
 local b=Instance.new('TextButton');b.Name=name;b.Text=text;b.Size=size;b.Position=pos
 b.BackgroundColor3=color;b.TextColor3=Color3.fromRGB(250,246,235);b.Font=Enum.Font.GothamBold;b.TextSize=14
 b.BorderSizePixel=2;b.BorderColor3=Color3.fromRGB(15,23,36);b.Parent=parent;return b
end
local toggle=label(gui,'Toggle','DEBUG TP — STUDIO ONLY',UDim2.fromOffset(230,40),UDim2.new(1,-16,0,120),Color3.fromRGB(153,77,25))
toggle.AnchorPoint=Vector2.new(1,0)
local panel=Instance.new('ScrollingFrame');panel.Name='Destinations';panel.AnchorPoint=Vector2.new(1,0)
panel.Position=UDim2.new(1,-16,0,166);panel.Size=UDim2.new(0,230,1,-180)
panel.BackgroundColor3=Color3.fromRGB(22,30,46);panel.BorderSizePixel=2;panel.BorderColor3=Color3.fromRGB(209,130,51)
panel.ScrollBarThickness=5;panel.AutomaticCanvasSize=Enum.AutomaticSize.Y;panel.CanvasSize=UDim2.new();panel.Parent=gui
local bounds=Instance.new('UISizeConstraint');bounds.MaxSize=Vector2.new(230,350);bounds.Parent=panel
local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,6);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=panel
local padding=Instance.new('UIPadding');padding.PaddingTop=UDim.new(0,8);padding.PaddingBottom=UDim.new(0,8);padding.PaddingLeft=UDim.new(0,8);padding.PaddingRight=UDim.new(0,8);padding.Parent=panel
local destinations={
 {'ScrapBelt','Sprout Moon'}, {'DerelictField','Rust Crater'}, {'IceGraveyard','Frost Cove'},
 {'NebulaCurrent','Violet Wilds'}, {'AncientRuins','Relic Grove'}, {'SingularityEdge','Storm Reach'}, {'HOME','Return home'},
}
local busy=false;local requestNumber=0
for n,d in destinations do
 local button=label(panel,d[1],d[2],UDim2.new(1,-4,0,36),UDim2.new(),d[1]=='HOME'and Color3.fromRGB(42,106,82)or Color3.fromRGB(50,65,91))
 button.LayoutOrder=n
 button.Activated:Connect(function()
  if busy then return end
  busy=true;requestNumber+=1;local current=requestNumber
  toggle.Text='Travelling to '..d[2]..'…';remote:FireServer(d[1])
  task.delay(8,function()if busy and requestNumber==current then busy=false;toggle.Text='DEBUG TP — TRY AGAIN'end end)
 end)
end
toggle.Activated:Connect(function()panel.Visible=not panel.Visible end)
remote.OnClientEvent:Connect(function(success,message,position)
 local current=requestNumber
 if success and typeof(position)=='Vector3'and workspace.StreamingEnabled then
  pcall(function()player:RequestStreamAroundAsync(position,5)end)
 end
 if current~=requestNumber then return end
 busy=false;toggle.Text=success and 'DEBUG TP — '..message or message
 task.delay(3,function()if requestNumber==current and not busy then toggle.Text='DEBUG TP — STUDIO ONLY'end end)
end)
