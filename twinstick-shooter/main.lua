
display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")


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
_F =  "TitilliumWeb-Bold"

local gameState = display.newText("TwinStick Demo 0.1.0", _R-10, _B-10, _F, 16)
      gameState.anchorX, gameState.anchorY = 1, 1

local function keyEvents(event)
  if (system.getInfo("platform") == "android") then
    if (event.keyName == "back") then
      return false
    end
  end
  return false
end

Runtime:addEventListener("key", keyEvents)

composer.gotoScene("play")
