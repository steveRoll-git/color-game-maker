local inky = require "inky"
local useClick = require "ui.useClick"
local lg = love.graphics

return inky.defineElement(function(self, scene)
  useClick(self)

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1, self.props.down and 0.8 or (self.props.hovering and 0.6 or 0.4))
    lg.rectangle("fill", x, y, w, h, math.min(w, h) / 2)
  end
end)
