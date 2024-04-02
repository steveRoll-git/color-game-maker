local inky = require "inky"
local useClick = require "ui.useClick"
local lg = love.graphics

local menu = require "ui.menu"

local padding = 3

return inky.defineElement(function(self, scene)
  useClick(self)

  ---@type Inky.Element?
  local openMenu

  local function openMyMenu()
    if openMenu then
      return
    end
    openMenu = menu(scene)
    openMenu.props.items = self.props.items
    openMenu:__getInternal():initialize()
  end

  self:onPointer("press", function(element, pointer, ...)
    if openMenu then
      self:__getInternal():raiseOn("closeMenu")
      return
    end
    -- no need to close a currently open menu here, since that's already
    -- done in main.lua when we click outside the current menu
    openMyMenu()
  end)

  self:onPointerEnter(function(element, pointer)
    if ActiveMenu and not openMenu then
      scene:raise("closeMenu")
      openMyMenu()
    end
  end)

  self:on("closeMenu", function(element, ...)
    openMenu = nil
    ActiveMenu = nil
  end)

  return function(_, x, y, w, h)
    y = y + padding
    h = h - padding * 2
    local font = self.props.font or lg.getFont()
    if self.props.hovering or openMenu then
      lg.setColor(1, 1, 1, self.props.down and 0.3 or 0.2)
      lg.rectangle("fill", x, y, w, h, 4)
    end
    lg.setFont(font)
    lg.setColor(1, 1, 1)
    lg.printf(self.props.text, x, y + h / 2 - font:getHeight() / 2, w, "center")
    if openMenu then
      openMenu:render(x, y + h, 120, openMenu.props.desiredHeight())
    end
  end
end)
