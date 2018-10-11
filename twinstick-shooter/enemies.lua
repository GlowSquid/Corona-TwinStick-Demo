
local clean = require("clean")
local drops = require("drops")

local enemies = {}


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
    physics.addBody(asteroid[i], "dynamic", {friction=.8, bounce=.9, box=offsetRectParams, filter=asteroidFilter})
    local force = math.random()/10
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
    if enemy.health <= 0 then
      drops.explode(enemy)
    end
    if other.name == "blazer" then
      enemy.health = enemy.health - 15
      clean.cleanObj(other)
    elseif other.name == "player" then
      enemy.health = enemy.health - 10 - (percent * 10)
      other:setLinearVelocity(0, 0)
    end
  end
end
Runtime:addEventListener("collision", enemyCollision)

enemies.spawnAsteroid = spawnAsteroid

return enemies