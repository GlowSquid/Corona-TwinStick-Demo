
local clean = require("clean")

local miniMap = {}

  local mmSize = 2

  local scopeText = display.newText("2x", _R-20, _CH*.387, _F, 16)
        scopeText:setFillColor(.7, .7, .7)

  local miniMap = display.newGroup()
        miniMap.anchorX, miniMap.anchorY = 1, 0
        miniMap.x, miniMap.y = _R-10, _T+7
        miniMap.xScale = 1/20
        miniMap.yScale = 1/20

  local overlay = display.newRoundedRect(miniMap, _CW*.001, _CH*.001, 2500, 2500, 125)
        overlay:setFillColor(0, 0, .1, .3)
        overlay.strokeWidth = 25
        overlay:setStrokeColor(.1, .1, .4)
        overlay.anchorX, overlay.anchorY = 1, 0
        overlay.name = "zoom"

  local mmFrame = display.newContainer(miniMap, 2500, 2500)
        mmFrame.anchorX, mmFrame.anchorY = 1, 0


  local function mmEnterFrame(self)
    if (self.removeSelf == nil or
      not self.myObj or
      self.myObj.removeSelf == nil) then
        Runtime:removeEventListener("enterFrame", self)
        clean.cleanObj(self)
        return
    end
    if self.myObj == ship and ship.alive == true then
      self.rotation = ship.rotation
    end
    if ship.alive == true then
      self.x = self.myObj.x-ship.x
      self.y = self.myObj.y-ship.y
    else
    --  self.x = self.myObj.x-_CX
    --  self.y = self.myObj.y-_CY
      self.x = self.myObj.x-ship.x
      self.y = self.myObj.y-ship.y
    end
  end


  local function zoomMap(event)
    
    if (event.target.name == "zoom") then
      print("taps", mmSize)
      if mmSize == 2 then
        mmSize = 1 -- 1x
        scopeText.text = "1x"
        ship.mini.xScale, ship.mini.yScale = 2, 2
        miniMap.xScale = 1/40
        miniMap.yScale = 1/40
        mmFrame.width = mmFrame.width*2
        mmFrame.height = mmFrame.height*2
        overlay.xScale, overlay.yScale = 2, 2
        --asteroid[i].mini.xScale = 2
        --satellite.mini.xScale, satellite.mini.yScale = 2, 2
      elseif mmSize == 1 then
        mmSize = 3 -- 4x
        scopeText.text = "4x"
        miniMap.xScale = 1/10
        miniMap.yScale = 1/10
        mmFrame.width = mmFrame.width/4
        mmFrame.height = mmFrame.height/4
        overlay.xScale, overlay.yScale = .5, .5
        ship.mini.xScale, ship.mini.yScale = .5, .5
        --asteroid[i].mini.xScale, asteroid[i].mini.yScale = .5, .5
        --satellite.mini.xScale, satellite.mini.yScale = .5, .5
      elseif mmSize == 3 then
        mmSize = 2 -- 2x
        scopeText.text = "2x"
        miniMap.xScale = 1/20
        miniMap.yScale = 1/20
        mmFrame.width = mmFrame.width*2
        mmFrame.height = mmFrame.height*2
        overlay.xScale, overlay.yScale = 1, 1
        ship.mini.xScale, ship.mini.yScale = 1, 1
        --asteroid[i].mini.xScale, asteroid[i].mini.yScale = 1, 1
        --satellite.mini.xScale, satellite.mini.yScale = 1, 1
      end
    end
  end

  overlay:addEventListener("tap", zoomMap)


  miniMap.overview = overview
  miniMap.mmEnterFrame = mmEnterFrame
  miniMap.mmFrame = mmFrame
  miniMap.zoomMap = zoomMap

return miniMap