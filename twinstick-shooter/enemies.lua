
local clean = require("clean")
local drops = require("drops")
local miniMap = require("minimap")

local enemies = {}

local dummy = display.newText("", _CX, _CY, _F, 2)


local function spawnAsteroid()
  local asteroid = {}
  if initialSpawned == false then
    numAsteroids = 200
  else
    numAsteroids = 2
  end
  for i = 1, numAsteroids do
    local asteroidImg = ("gfx/ast" .. (math.random(1, 7)) .. ".png")
    asteroid[i] = display.newImage(asteroidImg)
    asteroid[i].x = math.random(-5000, 5000)
    asteroid[i].y = math.random(-5000, 6500)
    asteroid[i].xScale = math.random(1.1, 2) / 5
    asteroid[i].yScale = math.random(1.1, 2) / 5
    asteroid[i].rotation = math.random(0,359)
    asteroid[i].alpha = .01
    asteroid[i].type = "enemy"
    if math.random(2) == 1 then
      asteroid[i].name = "not only asteroid"
    else
      asteroid[i].name = "asteroid"
    end
    asteroid[i].image = asteroidImg
    asteroid[i].health = 100
    local offsetRectParams = { halfWidth=25+asteroid[i].xScale, halfHeight=25+asteroid[i].yScale, x=0, y=0}
    physics.addBody(asteroid[i], "dynamic", {friction=.8, bounce=.9, box=offsetRectParams, filter=asteroidFilter})
    local force = math.random()/10
    asteroid[i]:applyForce(force, (math.random(-1, 1) * force/2), asteroid.x, asteroid.y)
    transition.fadeIn(asteroid[i], {time=1000})
    transition.to(asteroid[i], {delay=math.random(100000, 200000), time=2000, alpha=.01, onComplete=clean.cleanObj})
    camera:add(asteroid[i], 2)
    if initialSpawned == false then
      initialSpawned = true
    end
    asteroid[i].mini = display.newCircle(asteroid[i].x-_CX, asteroid[i].y-_CY, 40)
    asteroid[i].mini:setFillColor(.5, .8, .5)
    asteroid[i].mini.myObj = asteroid[i]
    asteroid[i].mini.alpha = .01
    transition.fadeIn(asteroid[i].mini, {time=20})
    asteroid[i].mini.enterFrame = miniMap.mmEnterFrame
    miniMap.mmFrame:insert(asteroid[i].mini)
    Runtime:addEventListener("enterFrame", asteroid[i].mini)
  end
end

local function spawnKamikaze()
  local function charge(obj)
    local function despawn()
      clean.cleanObj(obj)
      --drops.explode(obj)
    end
    physics.addBody(obj, "dynamic", {filter=enemyFilter})
    local rad = math.sqrt ((obj.x - ship.x)^2 + (obj.y - ship.y)^2)
    
    transition.to(obj, {time=500, rotation=math.deg(math.atan2(ship.y-obj.y, ship.x-obj.x)) + 90})
    transition.to(obj, {delay=500, time=rad*2, x=ship.x, y=ship.y, onComplete=despawn, transition=easing.inSine})

  end

  local kamikaze = display.newImage("gfx/kamikaze.png", dummy.x, dummy.y)
        kamikaze.image = "gfx/kamikaze.png"
        kamikaze.type = "enemy"
        kamikaze.name = "kamikaze"
        kamikaze.health = 40
        kamikaze.xScale, kamikaze.yScale = .3, .3
        kamikaze.rotation = math.random(0, 359)
        camera:add(kamikaze, 3)
        transition.to(kamikaze, {time=20, onComplete=charge})

        kamikaze.mini = display.newCircle(kamikaze.x-_CX, kamikaze.y-_CY, 40)
        kamikaze.mini.alpha = .01
        kamikaze.mini:setFillColor(1, 0, 0)
        transition.fadeIn(kamikaze.mini, {time=20})
        kamikaze.mini.myObj = kamikaze
        kamikaze.mini.enterFrame = miniMap.mmEnterFrame
        miniMap.mmFrame:insert(kamikaze.mini)
        Runtime:addEventListener("enterFrame", kamikaze.mini)
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
      if enemy.name == "asteroid" then
        drops.explode(enemy)
      elseif enemy.name == "kamikaze" then
        drops.explode(enemy)
      elseif enemy.name == "not only asteroid" then
        dummy.x = enemy.x
        dummy.y = enemy.y
        spawnKamikaze()
        drops.explode(enemy)
      else
        print(enemy.name)
      end
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
enemies.spawnKamikaze = spawnKamikaze

return enemies