local inky = require "inky"
local useClick = require "ui.useClick"
local lg = love.graphics
local menuBarItem = require "ui.menuBarItem"

return inky.defineElement(function(self, scene)
  ---@type Inky.Element[]
  local items
  self:useEffect(function(element)
    items = {}
    for _, item in ipairs(self.props.items) do
      local mbItem = menuBarItem(scene)
      mbItem.props.text = item.text
      table.insert(items, mbItem)
    end
  end, "items")

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1, 0.3)
    lg.rectangle("fill", x, y, w, h)
    local itemX = x + 2
    for _, item in ipairs(items) do
      local itemW = (item.props.font or lg.getFont()):getWidth(item.props.text) + 16
      item:render(itemX, y, itemW, h)
      itemX = itemX + itemW
    end
  end
end)
