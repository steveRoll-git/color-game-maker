local inky = require "inky"
local lg = love.graphics
local palette = require "palette"
local paletteSquare = require "ui.paletteSquare"

return inky.defineElement(function(self, scene)
  ---@type Inky.Element[]
  local squares = {}
  for index, color in ipairs(palette) do
    local s = paletteSquare(scene)
    s.props.colorId = index
    table.insert(squares, s)
  end

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1)
    lg.setLineWidth(4)
    lg.rectangle("line", x, y, w, h)

    local sx, sy = x, y

    for index, square in ipairs(squares) do
      square:render(sx, sy, self.props.squareSize, self.props.squareSize)
      if index % self.props.columns == 0 then
        sy = sy + self.props.squareSize
        sx = x
      else
        sx = sx + self.props.squareSize
      end
    end

    ---@diagnostic disable-next-line: undefined-field
    squares[CurrentColor]:renderOutline()
  end
end)