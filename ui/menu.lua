local inky = require "inky"
local useClick = require "ui.useClick"
local lg = love.graphics

local menuItem = inky.defineElement(function(self, scene)
  useClick(self)
  return function(_, x, y, w, h)
    local font = self.props.font or lg.getFont()
    if self.props.hovering then
      lg.setColor(1, 1, 1, self.props.down and 0.3 or 0.2)
      lg.rectangle("fill", x, y, w, h, 4)
    end
    lg.setFont(font)
    lg.setColor(1, 1, 1)
    lg.print(self.props.text, x + 3, y + h / 2 - font:getHeight() / 2)
  end
end)

return inky.defineElement(function(self, scene)
  local padding = 3

  ---@type Inky.Element[]
  local items = {}
  self:useEffect(function(element)
    items = {}
    for _, item in ipairs(self.props.items) do
      local mbItem = menuItem(scene)
      mbItem.props.text = item.text
      table.insert(items, mbItem)
    end
  end, "items")

  self:onEnable(function(element)
    ActiveMenu = self
  end)

  local function itemHeight(item)
    return (item.props.font or lg.getFont()):getHeight() + 8
  end

  self.props.desiredHeight = function()
    local h = 0
    for _, item in ipairs(items) do
      h = h + itemHeight(item) + padding
    end
    return h
  end

  return function(_, x, y, w, h)
    lg.setColor(0.2, 0.2, 0.2)
    lg.rectangle("fill", x, y, w, h, 4)
    local itemY = y + padding
    for _, item in ipairs(items) do
      local itemH = itemHeight(item)
      item:render(x + padding, itemY, w - padding * 2, itemH)
      itemY = itemY + itemH
    end
  end
end)
