local inky = require "inky"
local lg = love.graphics
local palette = require "palette"
local hexToColor = require "hexToColor"

return inky.defineElement(function(self, scene)
  self:onPointer("press", function(element, pointer, ...)
    CurrentColor = self.props.colorId
  end)

  function self:renderOutline()
    local x, y, w, h = self:getView()
    lg.setColor(1, 1, 1)
    lg.setLineWidth(6)
    lg.rectangle("line", x - 2, y - 2, w + 4, h + 4)

    lg.setColor(0, 0, 0)
    lg.setLineWidth(3)
    lg.rectangle("line", x - 2, y - 2, w + 4, h + 4)
  end

  return function(_, x, y, w, h)
    lg.setColor(hexToColor(palette[self.props.colorId]))
    lg.rectangle("fill", x, y, w, h)
  end
end)