local inky = require "inky"
local useClick = require "ui.useClick"
local lg = love.graphics

return inky.defineElement(function(self, scene)
  useClick(self)

  self:onPointer("press", function(element, pointer, ...)
    CurrentFrame = self.props.frameId
    scene:raise("frameChange")
  end)

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1, CurrentFrame == self.props.frameId and 0.3 or (self.props.hovering and 0.1 or 0))
    lg.rectangle("fill", x, y, w, h)

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
      local image = Project.frames[self.props.frameId].drawableImage
      lg.setColor(1, 1, 1)
      lg.draw(image, imageX, imageY, 0, scale)
    else
      lg.setColor(0, 0, 0)
      lg.rectangle("fill", imageX, imageY, targetW, targetH)
    end

    local font = self.props.font or love.graphics.getFont()

    lg.setFont(font)
    lg.setColor(1, 1, 1)
    lg.printf(self.props.frameId, x, y + h / 2 - font:getHeight() / 2, imageX, "center")
  end
end)
