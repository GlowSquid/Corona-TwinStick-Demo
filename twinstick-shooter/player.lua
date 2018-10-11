
local player = {}

local maxBarWidth = 1200


local function addPhysics()
  local offsetRectParams = { halfWidth=20, halfHeight=35, x=0, y=0}
  physics.addBody(ship, "dynamic", {box=offsetRectParams, filter=playerFilter})
end


local function spawnPlayer()
  ship = display.newImage("gfx/ship.png", _CX, _CY)
  ship.image = "gfx/ship.png"
  ship.xScale, ship.yScale = .3, .3
  ship.alive = true
  ship.name = "player"
  ship.health = 100
  ship.maxHealth = 100
  ship:setFillColor(.5, 1, .3)
  camera:add(ship, 2)
end


local function playerCollision(event)
  local ship
  local other
  if event.object1.name == "player" then
    ship = event.object1
    other = event.object2
  elseif event.object2.name == "player" then
    ship = event.object2
    other = event.object1
  end
  if ship then
    if ship.health <= 0 then
      ship.alive = false
    end
    if other.name == "asteroid" then
      ship.health = ship.health - 10 - (percent * 10)
      print(ship.health)
      healthBar.width = (ship.health / ship.maxHealth) * maxBarWidth
    end
  end
end
Runtime:addEventListener("collision", playerCollision)


player.addPhysics = addPhysics
player.spawnPlayer = spawnPlayer


return player