require "globals"
local ui = require "ui"

local inky = require "inky"

local scene = inky.scene()
local pointer = inky.pointer(scene)

local framesPanel = ui.framesPanel(scene)
framesPanel.props.frameHeightRatio = 0.48

function love.update(dt)
  local prevX, prevY = pointer:getPosition()
  local mx, my = love.mouse.getPosition()
  pointer:setPosition(mx, my)
  if mx ~= prevX or my ~= prevY then
    pointer:raise("move", mx - prevX, my - prevY)
  end
end

function love.mousepressed(x, y, b)
  pointer:setPosition(x, y)
  if b == 1 then
    pointer:raise("press")
  end
end

function love.mousereleased(x, y, b)
  pointer:setPosition(x, y)
  if b == 1 then
    pointer:raise("release")
  end
end

function love.wheelmoved(x, y)
  pointer:raise("wheelmoved", x, y)
end

function love.resize()
  love.draw()
  scene:raise("resize")
end

function love.draw()
  scene:beginFrame()
  
  framesPanel:render(0, 0, 200, love.graphics.getHeight())

  scene:finishFrame()
end