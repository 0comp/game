local holder=Instance.new("Folder")
local module=game.ReplicatedStorage.ClickerKit.Interface:Clone()
module.Parent=game.ReplicatedStorage.ClickerKit
local ok,result=xpcall(function()
    local v=require(module).Build(holder)
    local results={}
    for _,size in ipairs({Vector2.new(390,844),Vector2.new(844,390),Vector2.new(375,667),Vector2.new(1280,800)}) do
        v:Layout(size)
        local s=v.Gui.Background.Canvas.ResponsiveScale.Scale
        local bottom=size.Y+v.Toast.Position.Y.Offset-v.Toast.AnchorPoint.Y*v.Toast.Size.Y.Offset
        local top=bottom+v.Toast.Size.Y.Offset
        if v.Compact then
            local tabsTop=size.Y-39-46*s
            assert(top<=tabsTop-11, "Notification covers mobile tabs at "..tostring(size))
        else
            assert(v.Toast.Position.Y.Offset==-12, "Desktop notification moved")
        end
        assert(bottom>0,"Notification leaves viewport")
        table.insert(results,{Viewport=tostring(size),Passed=true})
    end
    return results
end,debug.traceback)
holder:Destroy(); module:Destroy()
assert(ok,result)
return game.HttpService:JSONEncode(result)
