local love = love
local lg = love.graphics

local inky = require "inky"

local function useClick(self)
  self.props.hovering = false
  self.props.down = false

  self:onPointerEnter(function(element, pointer)
    self.props.hovering = true
  end)
  self:onPointerExit(function(element, pointer)
    self.props.hovering = false
  end)
end

local ui = {}

ui.scrollBar = inky.defineElement(function(self, scene)
  useClick(self)

  self:onPointer("press", function(element, pointer, ...)
    self.props.down = true
    pointer:captureElement(self, true)
  end)
  self:onPointer("release", function(element, pointer, ...)
    self.props.down = false
    pointer:captureElement(self, false)
  end)

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1, self.props.down and 0.8 or (self.props.hovering and 0.6 or 0.4))
    lg.rectangle("fill", x, y, w, h, math.min(w, h) / 2)
  end
end)

ui.framePreview = inky.defineElement(function(self, scene)
  useClick(self)

  self:onPointer("press", function(element, pointer, ...)
    CurrentFrame = self.props.frameId
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
      local image = Project.frames[self.props.frameId].image
      lg.setColor(1, 1, 1)
      lg.draw(image, imageX, imageY)
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

ui.framesPanel = inky.defineElement(function(self, scene)
  ---@type Inky.Element[]
  local frameElements = {}

  for i = 1, MaxFrames do
    local frame = ui.framePreview(scene)
    frame.props.frameId = i
    table.insert(frameElements, frame)
  end

  local scrollBar = ui.scrollBar(scene)
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
      local _, _, _, h = self:getView()
      local newY = barY + dy
      setScroll(newY / h * self.props.contentH)
    end
  end)

  self:on("resize", function(element, ...)
    -- so that invalid scroll positions will not happen
    setScroll(self.props.scrollY)
  end)

  return function(_, x, y, w, h)
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
      (self.props.scrollY / self.props.contentH) * h,
      self.props.scrollBarW,
      h / self.props.contentH * h)
  end
end)

return ui
