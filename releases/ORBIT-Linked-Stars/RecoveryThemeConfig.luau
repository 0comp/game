-- Version 3-compatible recovery mode. Replace ClickerKit.ThemeConfig with this
-- only when disabling travel/discovery/interstellar purchases is necessary.
local config=require(script.Parent.Themes:WaitForChild("Space"))
config.StarTransitionsEnabled=false
return config
