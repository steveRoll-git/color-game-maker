local inky = require "inky"
local lg = love.graphics

local useClick = require "ui.useClick"
local useContained = require "ui.useContained"
local scrollBar = require "ui.scrollBar"
local framePreview = require "ui.framePreview"

return inky.defineElement(function(self, scene)
  useClick(self)

  ---@type Inky.Element[]
  local frameElements = {}

  for i = 1, MaxFrames do
    local frame = framePreview(scene)
    frame.props.frameId = i
    useContained(frame, scene)
    table.insert(frameElements, frame)
  end

  local scrollBar = scrollBar(scene)
  self.props.scrollBarW = 12

  self.props.scrollY = 0

  local function setScroll(y)
    local _, _, _, h = self:getView()
    self.props.scrollY = math.min(math.max(y, 0), self.props.contentH - h)
  end

  self:onPointer("wheelmoved", function(element, pointer, x, y)
    setScroll(self.props.scrollY - y * self.props.frameH / 4 * 3)
  end)

  scrollBar:onPointer("move", function(element, pointer, dx, dy)
    if scrollBar.props.down then
      local _, barY, _, _ = scrollBar:getView()
      local _, y, _, h = self:getView()
      local newY = barY + dy
      setScroll((newY - y) / h * self.props.contentH)
    end
  end)

  self:on("resize", function(element, ...)
    -- so that invalid scroll positions will not happen
    setScroll(self.props.scrollY)
  end)

  return function(_, x, y, w, h)
    lg.setScissor(x, y, w, h)

    lg.setColor(0.5, 0.5, 0.5, 0.5)
    lg.rectangle("fill", x, y, w, h)

    local frameY = y - self.props.scrollY
    self.props.frameH = w * self.props.frameHeightRatio
    self.props.contentH = MaxFrames * self.props.frameH

    for i = 1, MaxFrames do
      frameElements[i]:render(x, frameY, w - self.props.scrollBarW, self.props.frameH)
      frameY = frameY + self.props.frameH
    end

    scrollBar:render(
      x + w - self.props.scrollBarW,
      y + (self.props.scrollY / self.props.contentH) * h,
      self.props.scrollBarW,
      h / self.props.contentH * h)

    lg.setScissor()
  end
end)
