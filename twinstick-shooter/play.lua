
local composer = require( "composer" )
 
local scene = composer.newScene()
local stickLib = require("lib_analog_stick")
local clean = require("clean")
local physics = require("physics")
local perspective = require("perspective")
local enemies = require("enemies")


initialSpawned = false

 
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

  local nebula = display.newImage("gfx/nebula.png", _CX, _CY)
        nebula.alpha = .5
        nebula.xScale, nebula.yScale = 3.5, 3.5
        camera:add(nebula, 9)

  local starsBig = display.newImage("gfx/starsBig.png", _CX, _CY)
        camera:add(starsBig, 11)
  local stars = display.newImage("gfx/stars.png", _CX, _CY)
        camera:add(stars, 12)
  
  local galaxy = display.newImage("gfx/galaxy.png", _CX, _CY)
        galaxy.xScale, galaxy.yScale = 3, 3
        galaxy:setFillColor(0, 1, 1, .5)
        camera:add(galaxy, 12)

  local function universeSpin()
    galaxy.rotation = 0
    stars.rotation = 0
    starsBig.rotation = 0
    transition.to(galaxy, {time=200000, x=_CX-500, y=_CY-700, rotation=-180})
    transition.to(galaxy, {delay=200000, time=100000, x=_CX, y=_CY, rotation=-360})
    transition.to(stars, {time=400000, rotation=-360})
    transition.to(starsBig, {time=400000, rotation=360, onComplete=universeSpin})
  end
  universeSpin()

  local function starBlink()
    delayTime = math.random(5000, 15000)
    transition.to(stars, {delay=delayTime, time=100, alpha=0})
    transition.to(stars, {delay=delayTime+100, time=100, alpha=1, onComplete=starBlink})
  end
  starBlink()

  local planet = display.newImage("gfx/planet_19.png", _CX-300, _CY+1200)
        planet.xScale, planet.yScale = 2.8, 2.8
        camera:add(planet, 8)

  local planet2 = display.newImage("gfx/planet_18.png", _CX-500, _CY+2000)
        planet2.xScale, planet2.yScale = .5, .5
        camera:add(planet2, 6)
        

  local function planetRotate()
    transition.to(planet, {time=400000, x=_CX-600, y=_CY+900, rotation=180})
    transition.to(planet2, {time=400000, x=_CX-800, y=_CY+1700, rotation=180})
    transition.to(planet, {delay=400000, x=_CX-300, y=_CY+1200, time=400000, rotation=360})
    transition.to(planet2, {delay=400000, x=_CX-500, y=_CY+2000, time=400000, rotation=360, onComplete=planetRotate})

  end
  planetRotate()

  local station = display.newImage("gfx/satellite.png", _CX-1400, _CY+600)
        camera:add(station, 4)


  local player = display.newImage("gfx/ship.png", _CX, _CY)
        player.xScale, player.yScale = .4, .4
        player.alive = true
        player.name = "player"
        player:setFillColor(.5, 1, .3)
        camera:add(player, 2)
        

  local navPad = stickLib.NewStick({thumbSize=8, borderSize=32, snapBackSpeed=.93, R=.2, G=.6, B=.8})
        navPad.x = _CW*.10
        navPad.y = _CH*.8

  

  function nav(event)
    angle = navPad:getAngle()
    disting = navPad:getDistance()
    percent = navPad:getPercent()
    moving = navPad:getMoving()
    if not player.alive then
      Runtime:removeEventListener("enterFrame", nav)
      return
    end
    navPad:move(player, 35, true)
    --print(disting)
    if not (disting == 0) then
--    if moving == true then
      local trail = display.newImage("gfx/trail.png", player.x+math.random(-5, 5), player.y+math.random(-5, 5))
            trail.xScale, trail.yScale = player.xScale*percent+.01, player.yScale*percent*1.4+.01
            trail.rotation = angle
            trail.alpha = percent
            camera:add(trail, 3)
            transition.to(trail, {time=50, xScale=.01, yScale=.01, alpha=.01, onComplete=clean.cleanObj})
            --print(percent)
    end
    
  end

  local shootPad = stickLib.NewStick({thumbSize=8, borderSize=32, snapBackSpeed=0, R=.2, G=.8, B=.2})
        shootPad.x = _CW*.9
        shootPad.y = _CH*.8

  function shoot(event)
    local padMoves = math.ceil(shootPad:getPercent()*100)
    local padHalfMoves = math.ceil(shootPad:getPercent()*50)
    function shoot()
      if player.alive == true then
        local angle = shootPad:getAngle()
        local blazer = display.newImage("gfx/blazer.png", player.x, player.y)
              blazer.xScale, blazer.yScale = .1, .2
              blazer.alpha = 1
              blazer.rotation = angle
              blazer.name = "blazer"
              camera:add(blazer, 2)
              local offsetRectParams = { halfWidth=6, halfHeight=20, x=0, y=0}
              physics.addBody(blazer, "dynamic", {isSensor=true, isBullet=true, box=offsetRectParams})
        local blazerSpeed = 500
              blazer:setLinearVelocity(math.sin(math.rad(shootPad:getAngle()))*blazerSpeed, math.cos(math.rad(shootPad:getAngle())) * -blazerSpeed)
        transition.to(blazer, {time=100, alpha=1})
        transition.to(blazer, {time=700, xScale=.1, yScale=.1, onComplete=clean.cleanObj})
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
    if not player.alive then
      Runtime:removeEventListener("enterFrame", shoot)
      return
    end
  end

  --local dummy = display.newText(sceneGroup, "", _CX, _CY, _F, 10)

  local function initialize()
    local function start()
      --physics.addBody(player, {radius=50})
      local offsetRectParams = { halfWidth=20, halfHeight=35, x=0, y=0}
      physics.addBody(player, "dynamic", {box=offsetRectParams})
      enemies.spawnAsteroid()
      asteroidTimer = timer.performWithDelay(2000, enemies.spawnAsteroid, 0)
      
      local function playerLoc(event)
        print(player:getLinearVelocity())
      end
      --Runtime:addEventListener("enterFrame", playerLoc)
    end
    
    camera:setFocus(player)
    transition.to(player, {time=1000, xScale=.25, yScale=.25, transition=easing.outSine, onComplete=start})
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