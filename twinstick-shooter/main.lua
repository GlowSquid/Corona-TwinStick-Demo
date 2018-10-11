
display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

perspective = require("perspective")
local composer = require("composer")
composer.isDebug = true


_CW = display.contentWidth
_CH = display.contentHeight
_CX = display.contentWidth*0.5
_CY = display.contentHeight*0.5
_T = display.screenOriginY
_L = display.screenOriginX
_R = display.viewableContentWidth-_L
_B = display.viewableContentHeight-_T
_F =  "TitilliumWeb"


-- Collision Filters
local playerFilter = {categoryBits = 1, maskBits = 22}
local asteroidFilter = {categoryBits = 2, maskBits = 9}
local enemyFilter  = {categoryBits = 4, maskBits = 9}
local bulletFilter = {categoryBits = 8, maskbits = 6}
local dropFilter = {categoryBits = 16, maskbits = 1}

-- Exiting with back-key
local function keyEvents(event)
  if (system.getInfo("platform") == "android") then
    if (event.keyName == "back") then
      return false
    end
  end
  return false
end
Runtime:addEventListener("key", keyEvents)


local gameState = display.newText("TwinStick Demo 0.3.0", _R-10, _B-10, _F, 16)
      gameState.anchorX, gameState.anchorY = 1, 1


composer.gotoScene("play")
