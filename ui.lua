local love = love
local lg = love.graphics

local inky = require "inky"
local dist = require "dist"
local palette = require "palette"
local hexToColor = require "hexToColor"

local function clickPointerEnter(self)
  self.props.hovering = true
end

local function clickPointerExit(self)
  self.props.hovering = false
end

local function clickPointerPress(self, pointer)
  self.props.down = true
  pointer:captureElement(self, true)
end

local function clickPointerRelease(self, pointer)
  self.props.down = false
  pointer:captureElement(self, false)
end

local function useClick(self)
  self:onPointerEnter(clickPointerEnter)
  self:onPointerExit(clickPointerExit)
  self:onPointer("press", clickPointerPress)
  self:onPointer("release", clickPointerRelease)
end

local ui = {}

ui.scrollBar = inky.defineElement(function(self, scene)
  useClick(self)

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1, self.props.down and 0.8 or (self.props.hovering and 0.6 or 0.4))
    lg.rectangle("fill", x, y, w, h, math.min(w, h) / 2)
  end
end)

ui.framePreview = inky.defineElement(function(self, scene)
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


ui.imageEditor = inky.defineElement(function(self, scene)
  useClick(self)

  local function currentColor()
    return hexToColor(palette[CurrentColor])
  end

  local function inRange(x, y)
    return x >= 0 and x < self.props.imageData:getWidth() and y >= 0 and y < self.props.imageData:getHeight()
  end

  local function updateImage()
    if self.props.drawableImage:getWidth() ~= self.props.imageData:getWidth() or
        self.props.drawableImage:getHeight() ~= self.props.imageData:getHeight() then
      self.props.drawableImage = lg.newImage(self.props.imageData)
    else
      self.props.drawableImage:replacePixels(self.props.imageData)
    end
  end

  ---@param pointer Inky.Pointer
  local function screenToImage(pointer)
    local x, y, w, h = self:getView()
    local px, py = pointer:getPosition()
    return
        math.floor((px - x) / w * self.props.imageData:getWidth()),
        math.floor((py - y) / h * self.props.imageData:getHeight())
  end

  local function setPixel(x, y, color)
    if inRange(x, y) then
      self.props.imageData:setPixel(x, y, color)
    end
  end

  -- Algorithm from http://members.chello.at/easyfilter/bresenham.html
  local function fillEllipse(x0, y0, x1, y1, color)
    if (x0 == x1 and y0 == y1) then
      setPixel(x0, y0, color)
      return
    end
    local a = math.abs(x1 - x0)
    local b = math.abs(y1 - y0)
    local b1 = b % 2
    local dx = 4 * (1 - a) * b * b
    local dy = 4 * (b1 + 1) * a * a
    local err = dx + dy + b1 * a * a
    local e2

    if (x0 > x1) then
      x0 = x1
      x1 = x1 + a
    end
    if (y0 > y1) then
      y0 = y1
    end
    y0 = y0 + (b + 1) / 2
    y1 = y0 - b1
    a = a * 8 * a
    b1 = 8 * b * b

    repeat
      for x = x0, x1 do
        setPixel(x, y0, color)
        setPixel(x, y1, color)
      end
      e2 = 2 * err
      if (e2 <= dy) then
        y0 = y0 + 1
        y1 = y1 - 1
        dy = dy + a
        err = err + dy
      end
      if (e2 >= dx or 2 * err > dy) then
        x0 = x0 + 1
        x1 = x1 - 1
        dx = dx + b1
        err = err + dx
      end
    until (x0 > x1)

    while (y0 - y1 < b) do
      setPixel(x0 - 1, y0, color)
      setPixel(x1 + 1, y0, color)
      y0 = y0 + 1
      setPixel(x0 - 1, y1, color)
      setPixel(x1 + 1, y1, color)
      y1 = y1 - 1
    end
  end

  local function paintCircle(toX, toY, fromX, fromY, color)
    local size = CurrentToolSize

    local currentX, currentY = fromX, fromY

    local dirX, dirY = toX - fromX, toY - fromY
    local step = math.abs(dirX) > math.abs(dirY) and math.abs(dirX) or math.abs(dirY)
    local nextX, nextY = currentX, currentY

    local count = 0

    repeat
      currentX = nextX
      currentY = nextY
      local x = currentX + 0.5
      local y = currentY + 0.5
      local x1, y1 = x - size / 2, y - size / 2
      local x2, y2 = x + size / 2 - 1, y + size / 2 - 1
      fillEllipse(x1, y1, x2, y2, color)
      nextX, nextY = currentX + dirX / step, currentY + dirY / step
      count = count + 1
    until dist(currentX, currentY, toX, toY) <= 0.5
  end

  local function updateImages()
    if Project.frames[CurrentFrame] then
      self.props.imageData = Project.frames[CurrentFrame].imageData
      self.props.drawableImage = Project.frames[CurrentFrame].drawableImage
    else
      self.props.imageData = nil
      self.props.drawableImage = nil
    end
  end

  local function prepareFrame()
    if not Project.frames[CurrentFrame] then
      Project.frames[CurrentFrame] = CreateFrame()
      updateImages()
    end
  end

  self:onPointer("press", function(element, pointer, ...)
    prepareFrame()
    local ix, iy = screenToImage(pointer)
    self.props.prevX, self.props.prevY = ix, iy
    paintCircle(ix, iy, ix, iy, { currentColor() })
    updateImage()
  end)

  self:onPointer("move", function(element, pointer, ...)
    if self.props.down then
      local ix, iy = screenToImage(pointer)
      paintCircle(self.props.prevX, self.props.prevY, ix, iy, { currentColor() })
      updateImage()
      self.props.prevX, self.props.prevY = ix, iy
    end
  end)

  self:on("frameChange", function(element, ...)
    updateImages()
  end)

  return function(_, x, y, w, h)
    lg.setColor(1, 1, 1)
    lg.setLineWidth(5)
    lg.rectangle("line", x, y, w, h)

    if self.props.drawableImage then
      lg.setColor(1, 1, 1)
      lg.draw(self.props.drawableImage,
        x,
        y,
        0,
        w / self.props.drawableImage:getWidth(),
        h / self.props.drawableImage:getHeight())
    else
      lg.setColor(0, 0, 0)
      lg.rectangle("fill", x, y, w, h)
    end
  end
end)

ui.paletteSquare = inky.defineElement(function(self, scene)
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

ui.palettePanel = inky.defineElement(function(self, scene)
  ---@type Inky.Element[]
  local squares = {}
  for index, color in ipairs(palette) do
    local s = ui.paletteSquare(scene)
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



return ui
