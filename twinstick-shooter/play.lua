
local composer = require( "composer" )
local scene = composer.newScene()

local perspective = require("perspective")
local stickLib = require("lib_analog_stick")
local physics = require("physics")
local clean = require("clean")
local player = require("player")
local enemies = require("enemies")
local miniMap = require("minimap")
local drops = require("drops")


initialSpawned = false
credits = 0
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  camera = perspective.createView(12)
  camera:setParallax(1, 1, 1, 0.9, 0.6, 0.5, 0.4, 0.3, 0.2, 0.03, 0.02, 0.01)
  camera:setBounds(_CX-5000, _CX+5000, _CY-5000, _CY+6500)
  sceneGroup:insert(camera)
  camera.damping = 2
  camera:track()

  sceneGroup:insert(miniMap)


  local nebula = display.newImage("gfx/nebula.png", _CX, _CY)
        --nebula.alpha = .5
        nebula.xScale, nebula.yScale = 3.5, 3.5
        camera:add(nebula, 9)
        nebula:setFillColor(1, 1, 1, .5)

  local starsBig = display.newImage("gfx/starsBig.png", _CX, _CY)
        camera:add(starsBig, 11)
  local stars = display.newImage("gfx/stars.png", _CX, _CY-200)
        camera:add(stars, 12)
  
  local galaxy = display.newImage("gfx/galaxy.png", _CX, _CY)
        galaxy.xScale, galaxy.yScale = 3, 3
        galaxy:setFillColor(0, 1, 1, .5)
        camera:add(galaxy, 12)

  local function universeSpin()
    galaxy.rotation = 0
    starsBig.rotation = 0
    transition.to(galaxy, {time=200000, x=_CX-500, y=_CY-700, rotation=-180})
    transition.to(galaxy, {delay=200000, time=100000, x=_CX, y=_CY, rotation=-360})
    transition.to(stars, {time=200000, y=_CY+200, x=_CX-100, xScale=1.2, yScale=1.2, transition=easing.inOutSine})
    transition.to(stars, {delay=200000, time=200000, y=_CY-200, xScale=1, yScale=1, x=_CX+100, transition=easing.inOutSine})
    transition.to(starsBig, {time=400000, rotation=360})
    transition.to(starsBig, {time=100000, xScale=1.5, yScale=1.5})
    transition.to(starsBig, {delay=100000, time=100000, xScale=1, yScale=1})
    transition.to(starsBig, {delay=200000, time=100000, xScale=1.5, yScale=1.5})
    transition.to(starsBig, {delay=300000, time=100000, xScale=1, yScale=1})
    transition.to(nebula.fill, {time=100000, r=.2, g=.2, b=1})
    transition.to(nebula.fill, {delay=100000, time=100000, r=0, g=0, b=0})
    transition.to(nebula.fill, {delay=200000, time=100000, r=math.random(0, 1), g=math.random(0, 1), b=math.random(0, 1)})
    transition.to(nebula.fill, {delay=300000, time=100000, r=1, g=1, b=1, onComplete=universeSpin})
  end
  universeSpin()


  local function starBlink()
    delayTime = math.random(5000, 15000)
    transition.to(stars, {delay=delayTime, time=100, alpha=0})
    transition.to(stars, {delay=delayTime+100, time=100, alpha=1, onComplete=starBlink})
  end
  starBlink()


  local planet = display.newImage("gfx/planet_19.png", _CX-300, _CY+1000)
        planet.xScale, planet.yScale = 2.5, 2.5
        camera:add(planet, 8)

  local planet2 = display.newImage("gfx/planet_18.png", _CX-500, _CY+2000)
        planet2.xScale, planet2.yScale = .5, .5
        camera:add(planet2, 6)

  local function planetRotate(obj)
    if obj == planet then
      startX = _CX-300
      startY = _CY+1000
      R = 1000
    elseif obj == planet2 then
      startX = _CX-500
      startY = _CY+2000
      R = 800
    end
    startX=_CX
    startY=_CY
    R = 1000
    obj.rotation = 0
    transition.to(obj, {time=800000, rotation=360})
    transition.to(obj, {time=400000, y=startY-R, transition=easing.inOutSine})
    transition.to(obj, {delay=400000, time=400000, y=startY+R, transition=easing.inOutSine})
    transition.to(obj, {time=200000, x=startX-R, transition=easing.outSine})
    transition.to(obj, {delay=200000, time=200000, x=startX, transition=easing.inSine})
    transition.to(obj, {delay=400000, time=200000, x=startX+R, transition=easing.outSine})
    transition.to(obj, {delay=600000, time=200000, x=startX, transition=easing.inSine, onComplete=planetRotate})
  end
  planetRotate(planet)
  planetRotate(planet2)


  local satellite = display.newImage("gfx/satellite.png", _CX-1000, _CY+600)
        camera:add(satellite, 4)
        satellite.mini = display.newImage("gfx/satellite.png", satellite.x, satellite.y)
        satellite.mini.myObj = satellite
        satellite.mini.rotation = satellite.rotation
        satellite.mini.enterFrame = miniMap.mmEnterFrame
        miniMap.mmFrame:insert(satellite.mini)
        Runtime:addEventListener("enterFrame", satellite.mini)


  -- Visual Stats
  local playerX = display.newText(sceneGroup, "X = 0", _L+5, _CH*.15, _F, 10)
        playerX.anchorX, playerX.anchorY = 0, 0
  local playerY = display.newText(sceneGroup, "Y = 0", _L+5, _CH*.18, _F, 10)
        playerY.anchorX, playerY.anchorY = 0, 0
  local playerAngle = display.newText(sceneGroup, "Angle = 0", _L+5, _CH*.21, _F, 10)
        playerAngle.anchorX, playerAngle.anchorY = 0, 0
  local playerSpeed = display.newText(sceneGroup, "Speed = 0.00", _L+5, _CH*.24, _F, 10)
        playerSpeed.anchorX, playerSpeed.anchorY = 0, 0


  local function destroyShip()
    local function restart()
      ship.x = _CX
      ship.y = _CH
      ship.alive = true
      ship.alpha = 1
      ship.health = ship.maxHealth
      healthBar.width = 1200
      Runtime:addEventListener("enterFrame", nav)
      --Runtime:addEventListener("enterFrame", shoot)
    end
    healthBar.width = 1
    ship.alpha = .01
    drops.explode(ship)
    percent = 0
    audio.play(sndBoom)
    transition.to(ship, {time=1000, onComplete=restart})
  end


  -- Left joypad
  local navPad = stickLib.NewStick({thumbSize=8, borderSize=26, snapBackSpeed=.93, R=.2, G=.6, B=.8})
        navPad.x = _CW*.10
        navPad.y = _CH*.8

  function nav(event)
    angle = navPad:getAngle()
    disting = navPad:getDistance()
    percent = navPad:getPercent()
    moving = navPad:getMoving()
    if not ship.alive then
      Runtime:removeEventListener("enterFrame", nav)
      destroyShip()
      return
    end
    navPad:move(ship, 10, true) -- Max player speed
    if not (disting == 0) and ship.alive == true then
      playerX.text = "X = " .. math.floor(ship.x)
      playerY.text = "Y = " .. math.floor(ship.y)
      playerAngle.text = "Angle = " .. angle
      playerSpeed.text = "Speed = " .. math.floor(percent * 100) / 100
      -- Zoom effect
      ship.xScale = .25 - (percent/15)
      ship.yScale = .25 - (percent/15)
      -- Enforcing borders
      if ship.x <= -5000 then
        ship.x = -5000
      elseif ship.x >= 5500 then
        ship.x = 5500
      end
      if ship.y <= -5000 then
        ship.y = -5000
      elseif ship.y >= 6800 then
        ship.y = 6800
      end

      local trail = display.newImage("gfx/trail.png", ship.x+math.random(-5, 5), ship.y+math.random(-5, 5))
            trail.xScale, trail.yScale = ship.xScale*percent+.01, ship.yScale*percent*1.4+.01
            trail.rotation = angle
            trail.alpha = percent
            camera:add(trail, 3)
            transition.to(trail, {time=50, xScale=.01, yScale=.01, alpha=.01, onComplete=clean.cleanObj})
    end
  end
  

  -- Right joypad
  local shootPad = stickLib.NewStick({thumbSize=8, borderSize=26, snapBackSpeed=0, R=1, G=.6, B=0})
        shootPad.x = _CW*.9
        shootPad.y = _CH*.8

  function shoot(event)
    local padMoves = math.ceil(shootPad:getPercent()*100)
    local padHalfMoves = math.ceil(shootPad:getPercent()*50)
    function shoot()
      if ship.alive == true then
        audio.play(sndShoot)
        local angle = shootPad:getAngle()
        local blazer = display.newImage("gfx/blazer.png", ship.x, ship.y)
              blazer.xScale, blazer.yScale = .1, .2
              blazer.alpha = 1
              blazer.rotation = angle
              blazer.name = "blazer"
              camera:add(blazer, 2)
              local offsetRectParams = { halfWidth=6, halfHeight=20, x=0, y=0}
              physics.addBody(blazer, "dynamic", {isSensor=true, isBullet=true, box=offsetRectParams, filter=bulletFilter})
        local blazerSpeed = 1000
              blazer:setLinearVelocity(math.sin(math.rad(shootPad:getAngle()))*blazerSpeed, math.cos(math.rad(shootPad:getAngle())) * -blazerSpeed)
        transition.to(blazer, {time=100, alpha=1})
        transition.to(blazer, {time=1000, xScale=.05, yScale=.1, onComplete=clean.cleanObj})

        blazer.mini = display.newImage("gfx/miniBlazer.png", blazer.x, blazer.y)
        blazer.mini.myObj = blazer
        --blazer.mini.rotation = blazer.rotation
        blazer.mini.xScale, blazer.mini.yScale = .3, .3
        blazer.mini.alpha = .01
        transition.fadeIn(blazer.mini, {time=20})
        blazer.mini.enterFrame = miniMap.mmEnterFrame
        miniMap.mmFrame:insert(blazer.mini)
        Runtime:addEventListener("enterFrame", blazer.mini)
        
      end
    end
    if (padMoves ~= 0) then
      if not shootTimer then
        shootTimer = timer.performWithDelay(70, shoot, 0)
      end
    else
      if shootTimer then
        timer.cancel(shootTimer)
        shootTimer = nil
      end
    end
    if not ship.alive then
      Runtime:removeEventListener("enterFrame", shoot)
      return
    end
  end

  local function healthRegen()
    if ship.health < ship.maxHealth then
      ship.health = ship.health + 1
      transition.to(healthBar, {time=200, width=(ship.health / ship.maxHealth) * 1200})
    end
  end


  local healthBarBg = display.newImage(sceneGroup, "gfx/barBg.png", _CW*.375, _CH*.8)
        healthBarBg.xScale, healthBarBg.yScale = .1, .1
        healthBarBg.anchorX, healthBarBg.anchorY = 0, 0
  
  healthBar = display.newImage(sceneGroup, "gfx/bar.png", _CW*.375, _CH*.8)
  healthBar.xScale, healthBar.yScale = .1, .1
  healthBar:setFillColor(1, .3, .5)
  healthBar.anchorX, healthBar.anchorY = 0, 0

  local function happy()
    credits = credits +1
    creditsText.text = credits
  end
  local creditsPanel = display.newRoundedRect(_CW*.05, _CH*.0495, _CW*.12, _CH*.05, 2)
        creditsPanel.strokeWidth = 1
        creditsPanel:setFillColor(0, 0, .1, .3)
        creditsPanel:setStrokeColor(.1, .1, .4)
        creditsText = display.newText("0", creditsPanel.x+20, creditsPanel.y, _F, 16)
        creditsText.anchorX = 1
        creditsText:setFillColor(.75, 1, .75)
  local creditsIcon = display.newImage("gfx/credit.png", creditsPanel.x-10, creditsPanel.y-4)
        creditsIcon.xScale, creditsIcon.yScale = .03, .03
        creditsIcon.rotation = 20
        creditsIcon:setFillColor(1, 1, .2)
        creditsIcon.anchorX, creditsIcon.anchorY = 1, 0

  local plusPanel = display.newRoundedRect(_CW*.12, _CH*.0495, _CW*.04, _CH*.05, 2)
        plusPanel.strokeWidth = 1
        plusPanel:setFillColor(.1, .1, .4)
        plusPanel:setStrokeColor(.1, .1, .4)
  local creditsPlus = display.newText("+", plusPanel.x+.5, plusPanel.y-2.5, _F, 26)
        creditsPlus:setFillColor(1, 1, .2)
        creditsPlus:addEventListener("touch", happy)


  local function initialize()
    local function start()
      player.addPhysics()
      enemies.spawnAsteroid()
      local asteroidTimer = timer.performWithDelay(1000, enemies.spawnAsteroid, 0)
      local regenTimer = timer.performWithDelay(1000, healthRegen, 0)

      local function playerLoc(event)
        print(ship:getLinearVelocity())
      end
      --Runtime:addEventListener("enterFrame", playerLoc)
    end
    player.spawnPlayer()
    camera:setFocus(ship)
    transition.to(ship, {time=1000, xScale=.25, yScale=.25, transition=easing.outSine, onComplete=start})
  end
  initialize()

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        physics.start()
        physics.setGravity(0, 0)
        physics.setDrawMode("normal")
        --physics.setDrawMode("hybrid")
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        
        Runtime:addEventListener("enterFrame", nav)
        Runtime:addEventListener("enterFrame", shoot)
        
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        Runtime:removeEventListener("enterFrame", nav)
        Runtime:removeEventListener("enterFrame", shoot)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene