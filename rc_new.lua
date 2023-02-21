pcall(require, "luarocks.loader")

local awful = require("awful")


screen.connect_signal("added", function(s)
	print(s)
end)

screen.connect_signal("list", function()
	print("list")
end)

for s in screen do
	print(s)
end
