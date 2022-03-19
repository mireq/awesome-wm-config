local setmetatable = setmetatable
local wrequire = require("vicious.helpers").wrequire

return setmetatable({ _NAME = "vicious_extra" }, { __index = wrequire })
