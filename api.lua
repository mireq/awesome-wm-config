local M = {}

function M:register(name, callable)
	self[name] = callable
end

return M
