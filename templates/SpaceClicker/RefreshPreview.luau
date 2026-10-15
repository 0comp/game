-- Run in Studio's Command Bar while Play is stopped.
local source = game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local temporary = source:Clone()
temporary.Name = "ClickerPreviewModules"
temporary.Parent = game:GetService("ReplicatedStorage")
local ok, result = pcall(function()
	local UI = require(temporary.UIBuilder)
	local view = UI.Build(game:GetService("StarterGui"))
	view.Gui:SetAttribute("Preview", true)
	view:Layout(workspace.CurrentCamera.ViewportSize)
	return "2D preview refreshed. Press Play to interact."
end)
temporary:Destroy()
assert(ok, result)
print(result)
