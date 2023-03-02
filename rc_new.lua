local a = function()
end

for s in screen do
	for i=0, 10000000 do
		s:connect_signal("property::geometry" , a)
		s:disconnect_signal("property::geometry" , a)
	end
end

awesome.quit();
