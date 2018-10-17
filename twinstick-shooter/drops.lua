
local miniMap = require("minimap")
local clean = require("clean")

local drops = {}

local function explode(obj)
  local function spawnDrop()
    local drop
    if math.random(10) == 1 then
      drop = display.newImage("gfx/dropHealth.png")
      drop.name = "healthDrop"
      drop.xScale, drop.yScale = .15, .15
    else
      drop = display.newImage("gfx/credit.png")
      drop.name = "credit"
      drop.xScale, drop.yScale = .05, .05
      drop:setFillColor(1, 1, 0)
    end
    drop.x = explosion.x+math.random(-10, 10)
    drop.y = explosion.y+math.random(-10, 10)
    physics.addBody(drop, "dynamic", {isSensor=true, radius=18, filter=dropFilter})
    local force = math.random()/10
    drop:applyForce(force, (math.random(-1, 1) * force/2), drop.x, drop.y)
    drop:applyTorque(.1)
    drop.rotation = math.random(-90, 90)
    camera:add(drop, 1)
    transition.to(drop, {delay=14000, time=1000, alpha=.01, onComplete=clean.cleanObj})

    drop.mini = display.newCircle(drop.x-_CX, drop.y-_CY, 40)
    drop.mini:setFillColor(0, 0, 0, .01)
    drop.mini.strokeWidth = 10
    drop.mini:setStrokeColor(0, .6, 0)
    drop.mini.alpha = .01
    transition.fadeIn(drop.mini, {time=20})
    drop.mini.myObj = drop
    drop.mini.enterFrame = miniMap.mmEnterFrame
    miniMap.mmFrame:insert(drop.mini)
    Runtime:addEventListener("enterFrame", drop.mini)
  end


  explosion = display.newImage(obj.image, obj.x, obj.y)
  explosion:setFillColor(.8, .3, .2)
  explosion.rotation = obj.rotation + 30
  explosion.xScale = obj.xScale * 1.5
  explosion.yScale = obj.yScale * 1.5
  camera:add(explosion, 2)

  if not(obj.name == "not only asteroid" or obj.name == "player") then
    transition.to(explosion, {time=50, rotation=20, onComplete=spawnDrop})
  else
    transition.to(explosion, {time=50, rotation=20})
  end
  transition.to(explosion, {time=500, xScale=.01, yScale=.01, alpha=0, y=obj.y+math.random(-90, 90), rotation=obj.rotation+math.random(-90, 90), onComplete=clean.cleanObj})
  if not(obj.name == "player") then
    clean.cleanObj(obj)
  end
end

drops.explode = explode

return drops