local love = love
local lg = love.graphics

local inky = require "inky"

local ui = {}

ui.framePreview = inky.defineElement(function(self, scene)
  return function(_, x, y, w, h)
    local targetH = h / 4 * 3
    local scale = targetH / FrameHeight
    local targetW = FrameWidth * scale
    local margin = (h - targetH) / 2
    local imageX = x + w - targetW - margin
    local imageY = y + margin

    lg.setLineWidth(3)
    lg.setColor(1, 1, 1)
    lg.rectangle("line", imageX, imageY, targetW, targetH)

    if Project.frames[self.props.frameId] then
      local image = Project.frames[self.props.frameId].image
      lg.setColor(1, 1, 1)
      lg.draw(image, imageX, imageY)
    end

    local font = self.props.font or love.graphics.getFont()

    lg.setFont(font)
    lg.setColor(1, 1, 1)
    lg.printf(self.props.frameId, x, y + h / 2 - font:getHeight() / 2, imageX, "center")
  end
end)

ui.framesPanel = inky.defineElement(function(self, scene)
  ---@type Inky.Element[]
  local frameElements = {}

  for i = 1, MaxFrames do
    local frame = ui.framePreview(scene)
    frame.props.frameId = i
    table.insert(frameElements, frame)
  end

  return function(_, x, y, w, h)
    lg.setColor(0.5, 0.5, 0.5, 0.5)
    lg.rectangle("fill", x, y, w, h)

    local frameY = y
    local frameH = w * self.props.frameHeightRatio
    local contentH = MaxFrames * frameH
    
    for i = 1, MaxFrames do
      frameElements[i]:render(x, frameY, w, frameH)
      frameY = frameY + frameH
    end
  end
end)

return ui
