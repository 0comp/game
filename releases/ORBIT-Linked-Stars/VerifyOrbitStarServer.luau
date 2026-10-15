-- Compile and wire the real server adapter against fake platform services.
local box=game.ServerStorage.OrbitLinkedTests
local calls,writes=0,0
local function signal()
    return {Connect=function(_,fn)calls+=1;return {Disconnect=function()end}end}
end
local remotes={}
for _,id in ipairs({"RequestAction","RequestClick","RequestPurchase","RequestZone","RequestPrestige","RequestSnapshot","StateUpdate"})do
    remotes[id]={OnServerEvent=signal(),FireClient=function()error("Unexpected real-player response")end}
end
local kit=setmetatable({Remotes=remotes},{__index=function(_,key)return box.Shared:FindFirstChild(key)end})
local players={PlayerAdded=signal(),PlayerRemoving=signal(),GetPlayers=function()return {}end,GetPlayerByUserId=function()return nil end}
local marketplace={PromptGamePassPurchaseFinished=signal()}
local services={Players=players,ReplicatedStorage={WaitForChild=function(_,name)assert(name=="ClickerKit");return kit end},MarketplaceService=marketplace,
    DataStoreService={GetDataStore=function()return {UpdateAsync=function()writes+=1;error("Unexpected save write")end}end},
    HttpService=game.HttpService,RunService={IsStudio=function()return false end}}
local fakeGame={JobId="isolated-test",GetService=function(_,name)return assert(services[name],name)end,BindToClose=function()end}
local noTasks={spawn=function()end,delay=function()end,wait=function()return 0 end}
local probe=Instance.new("ModuleScript");probe.Name="ServerWiringProbe"
local source=box.Server.ClickerServer.Source:gsub("script%.Parent%.Parent%.Shared",'ReplicatedStorage:WaitForChild("ClickerKit")')
probe.Source="return function(game,workspace,task)\n"..source.."\nreturn {Action=action,Receipt=processReceipt}\nend"
probe.Parent=box.Server
local ok,result=xpcall(function()
    local factory=require(probe)
    local hooks=factory(fakeGame,workspace,noTasks)
    assert(type(marketplace.ProcessReceipt)=="function" and calls==9)
    assert(hooks.Receipt({ProductId=0,PlayerId=123,PurchaseId="test"})==Enum.ProductPurchaseDecision.NotProcessedYet)
    hooks.Action({},"DiscoverSystem","Proxima")
    assert(writes==0,"Server probe attempted persistence")
    return {Total=1,Failures=0,Checks={{Name="server_adapter_compiles_and_wires_without_real_services",Passed=true}}}
end,debug.traceback)
probe:Destroy();assert(ok,result)
return game.HttpService:JSONEncode(result)
