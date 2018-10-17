
local clean = {}

local function cleanObj(obj)
  obj.alive = false
  display.remove(obj)
  obj = nil
end

clean.cleanObj = cleanObj

return clean