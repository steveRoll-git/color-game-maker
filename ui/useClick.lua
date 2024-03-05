---@param self Inky.Element
local function clickPointerEnter(self)
  self.props.hovering = true
end

---@param self Inky.Element
local function clickPointerExit(self)
  self.props.hovering = false
end

---@param self Inky.Element
---@param pointer Inky.Pointer
local function clickPointerPress(self, pointer)
  self.props.down = true
  pointer:captureElement(self, true)
end

---@param self Inky.Element
---@param pointer Inky.Pointer
local function clickPointerRelease(self, pointer)
  self.props.down = false
  pointer:captureElement(self, false)
end

---@param self Inky.Element
return function(self)
  self:onPointerEnter(clickPointerEnter)
  self:onPointerExit(clickPointerExit)
  self:onPointer("press", clickPointerPress)
  self:onPointer("release", clickPointerRelease)
end
