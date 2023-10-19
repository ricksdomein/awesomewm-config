-----------------------------------------------------------------------------------------------------------------------
--                                                    RedFlat library                                                --
-----------------------------------------------------------------------------------------------------------------------

local wrequire = require("redflat.util").wrequire
local setmetatable = setmetatable

local lib = { _NAME = "newflat.widget.bluetooth" }

return setmetatable(lib, { __index = wrequire })
