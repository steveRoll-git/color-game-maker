require "globals"
local ui = require "ui"

local inky = require "inky"

local scene = inky.scene()
local pointer = inky.pointer(scene)

local framesPanel = ui.framesPanel(scene)
framesPanel.props.frameHeightRatio = 0.5

function love.update(dt)
  pointer:setPosition(love.mouse.getPosition())
end

function love.draw()
  scene:beginFrame()
  
  framesPanel:render(0, 0, 200, love.graphics.getHeight())

  scene:finishFrame()
end