-- Compile the persistent platform adapter using fake input, remotes and controller.
local box=game.ServerStorage.OrbitLinkedTests
local count,requests=0,0
local function signal()return {Connect=function()count+=1;return {Disconnect=function()end}end}end
local remotes={StateUpdate={OnClientEvent=signal()},RequestAction={FireServer=function()error("Unexpected action")end},RequestSnapshot={FireServer=function()requests+=1 end}}
function remotes:WaitForChild(name)return self[name]end
local kit=setmetatable({Remotes=remotes},{__index=function(_,name)return box.Shared[name]end})
function kit:WaitForChild(name)return self[name]end
local player={UserId=123,WaitForChild=function()return {}end}
local platform={Players={LocalPlayer=player},MarketplaceService={PromptGamePassPurchaseFinished=signal(),PromptProductPurchaseFinished=signal()},
    UserInputService={InputBegan=signal(),InputChanged=signal()},StarterGui={SetCoreGuiEnabled=function()end},ReplicatedStorage={WaitForChild=function()return kit end}}
local fakeGame={GetService=function(_,name)return platform[name]end}
local fakeWorkspace={GetPropertyChangedSignal=function()return signal()end}
local fakeScript={Destroying=signal()}
local noTasks={spawn=function()end,wait=function()end}
local controller={new=function()return {View={ShopOffers={}},Destroy=function()end}end}
local source=box.Client.ClickerClient.Source:gsub("script%.Parent%.Parent%.Shared",'game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")')
source=source:gsub('local Controller=require%(script.Parent:WaitForChild%("StarClientController"%)%)','')
local probe=Instance.new("ModuleScript");probe.Name="ClientWiringProbe"
probe.Source="return function(game,workspace,task,script,Controller)\n"..source.."\nend";probe.Parent=box.Client
local ok,err=pcall(function()require(probe)(fakeGame,fakeWorkspace,noTasks,fakeScript,controller);assert(count==7 and requests==1)end)
probe:Destroy();assert(ok,err)
return game.HttpService:JSONEncode({Total=1,Failures=0,Checks={{Name="client_adapter_has_single_persistent_platform_listeners",Passed=true}}})
