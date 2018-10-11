

local clean = require("clean")

local drops = {}

local function explode(obj)
  explosion = display.newImage(obj.image, obj.x, obj.y)
  --explosion:setFillColor(.8, .3, .2)
  explosion.rotation = obj.rotation + 30
  explosion.xScale = obj.xScale * 1.5
  explosion.yScale = obj.yScale * 1.5
  camera:add(explosion, 2)
  transition.to(explosion, {time=50, rotation=20})
  transition.to(explosion, {time=500, xScale=.01, yScale=.01, alpha=0, y=obj.y+math.random(-90, 90), rotation=obj.rotation+math.random(-90, 90), onComplete=clean.cleanObj})
  if obj.name == "asteroid" then
    clean.cleanObj(obj)
  end
end

drops.explode = explode

return drops