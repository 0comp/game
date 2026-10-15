local Players=game:GetService('Players')
local UserInputService=game:GetService('UserInputService')
local shared=game:GetService('ReplicatedStorage'):WaitForChild('StarfallMap')
local view=require(shared.MapUI).Build(Players.LocalPlayer:WaitForChild('PlayerGui'))
UserInputService.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.M then view:SetOpen(not view.Window.Visible)
 elseif input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then view:SetOpen(false) end
end)
