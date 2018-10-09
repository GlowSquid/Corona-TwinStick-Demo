
local clean = {}

local function cleanObj(obj)
  display.remove(obj)
  obj = nil
end

clean.cleanObj = cleanObj

return clean