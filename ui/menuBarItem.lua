local inky = require "inky"
local useClick = require "ui.useClick"
local lg = love.graphics

local padding = 3

return inky.defineElement(function(self, scene)
  useClick(self)

  return function(_, x, y, w, h)
    y = y + padding
    h = h - padding * 2
    local font = self.props.font or lg.getFont()
    if self.props.hovering then
      lg.setColor(1, 1, 1, self.props.down and 0.3 or 0.2)
      lg.rectangle("fill", x, y, w, h, 4)
    end
    lg.setFont(font)
    lg.setColor(1, 1, 1)
    lg.printf(self.props.text, x, y + h / 2 - font:getHeight() / 2, w, "center")
  end
end)
