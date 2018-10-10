
local clean = require("clean")

local enemies = {}


local function explode(obj)
  explosion = display.newImage(obj.image, obj.x, obj.y)
  --explosion:setFillColor(.8, .3, .2)
  explosion.rotation = obj.rotation + 30
  explosion.xScale = obj.xScale * 1.5
  explosion.yScale = obj.yScale * 1.5
  camera:add(explosion, 2)
  transition.to(explosion, {time=50, rotation=20})
  transition.to(explosion, {time=500, xScale=.01, yScale=.01, alpha=0, y=obj.y+math.random(-90, 90), rotation=obj.rotation+math.random(-90, 90), onComplete=clean.cleanObj})
  clean.cleanObj(obj)
end


local function spawnAsteroid()
  local asteroid = {}
  if initialSpawned == false then
    numAsteroids = math.random(100, 300)
  else
    numAsteroids = 2
  end
  for i = 1, numAsteroids do
    --print("spam roids")
    local asteroidImg = ("gfx/ast" .. (math.random(1, 7)) .. ".png")
    asteroid[i] = display.newImage(asteroidImg)
    asteroid[i].x = math.random(-3000,3000)
    asteroid[i].y = math.random(-3000,5000)
    asteroid[i].xScale = math.random(1.1, 2) / 5
    asteroid[i].yScale = math.random(1.1, 2) / 5
    asteroid[i].rotation = math.random(0,359)
    asteroid[i].alpha = .01
    asteroid[i].type = "enemy"
    asteroid[i].name = "asteroid"
    asteroid[i].image = asteroidImg
    asteroid[i].health = 100
    local offsetRectParams = { halfWidth=25+asteroid[i].xScale, halfHeight=25+asteroid[i].yScale, x=0, y=0}
    physics.addBody(asteroid[i], "dynamic", {friction=.1, bounce=.2, box=offsetRectParams})
    local force = math.random()
    asteroid[i]:applyForce(force, (math.random(-1, 1) * force/2), asteroid.x, asteroid.y)
    --asteroid[i]:applyTorque(1)
    transition.fadeIn(asteroid[i], {time=1000})
    camera:add(asteroid[i], 2)
    if initialSpawned == false then
      initialSpawned = true
    end
  end
end

local function enemyCollision(event)
  local enemy
  local other
  if event.object1.type == "enemy" then
    enemy = event.object1
    other = event.object2
  elseif event.object2.type == "enemy" then
    enemy = event.object2
    other = event.object1
  end
  if enemy then
    if other.name == "blazer" then
      enemy.health = enemy.health - 15
      if enemy.health <= 0 then
        explode(enemy)
      end
      clean.cleanObj(other)
    elseif other.name == "player" then
      enemy.health = enemy.health - 10
      other:setLinearVelocity(0, 0)
    end
  end
end
Runtime:addEventListener("collision", enemyCollision)

enemies.spawnAsteroid = spawnAsteroid

return enemies