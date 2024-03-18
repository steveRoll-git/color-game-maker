---Makes an element raise a "press" event only if the mouse was inside the element's parent.
---@param self Inky.Element
---@param scene Inky.Scene
return function(self, scene)
  self:onPointer("press", function(element, pointer, ...)
    if scene:__getInternal():getElementParent(self).props.hovering then
      self:__getInternal():raiseOn("press")
    end
  end)
end
