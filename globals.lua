local hexToColor = require "hexToColor"
local palette = require "palette"

FrameWidth = 128
FrameHeight = 64

MaxFrames = 100

Project = {
  name = "Untitled Project",
  frames = {}
}

function CreateFrame()
  local imageData = love.image.newImageData(FrameWidth, FrameHeight)
  imageData:mapPixel(function()
    return hexToColor(palette[1])
  end)

  return {
    imageData = imageData,
    drawableImage = love.graphics.newImage(imageData)
  }
end

CurrentFrame = 1

CurrentColor = 1
CurrentToolSize = 1

---@type Inky.Element?
ActiveMenu = nil
