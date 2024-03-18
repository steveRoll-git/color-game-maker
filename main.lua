local love = love
local lg = love.graphics

lg.setDefaultFilter("linear", "nearest")

require "globals"
local palette = require "palette"

local inky = require "inky"

local scene = inky.scene()
local pointer = inky.pointer(scene)

local framesPanel = require "ui.framesPanel" (scene)
framesPanel.props.frameHeightRatio = 0.48

local framesPanelWidth = 200

local imageEditor = require "ui.imageEditor" (scene)

local paletteSquareSizes = { 36, 28, 16, 8 }

local palettePanel = require "ui.palettePanel" (scene)
palettePanel.props.squareSize = paletteSquareSizes[1]
palettePanel.props.columns = #palette / 2

local menuBar = require "ui.menuBar" (scene)
menuBar.props.items = {
  {
    text = "Project"
  },
  {
    text = "Slide"
  },
}
local menuBarHeight = 26

local paletteEditorMargin = 32

local frameScale = 1

local function updateFrameScale()
  local editorMaxW = lg.getWidth() - framesPanelWidth
  local editorMaxH = lg.getHeight()

  for _, size in ipairs(paletteSquareSizes) do
    if size * palettePanel.props.columns + 96 <= editorMaxW then
      palettePanel.props.squareSize = size
      break
    end
  end

  for i = 8, 1, -1 do
    local newW = FrameWidth * i
    local newH = FrameHeight * i + palettePanel.props.squareSize * 2 + paletteEditorMargin

    if newW <= editorMaxW and newH <= editorMaxH then
      frameScale = i
      break
    end
  end
end
updateFrameScale()

function love.update(dt)
  local prevX, prevY = pointer:getPosition()
  local mx, my = love.mouse.getPosition()
  pointer:setPosition(mx, my)
  if mx ~= prevX or my ~= prevY then
    pointer:raise("move", mx - prevX, my - prevY)
  end
end

function love.mousepressed(x, y, b)
  pointer:setPosition(x, y)
  if b == 1 then
    pointer:raise("press")
  end
end

function love.mousereleased(x, y, b)
  pointer:setPosition(x, y)
  if b == 1 then
    pointer:raise("release")
  end
end

function love.wheelmoved(x, y)
  pointer:raise("wheelmoved", x, y)
end

function love.resize(w, h)
  love.draw()
  scene:raise("resize")
  updateFrameScale()
end

function love.draw()
  scene:beginFrame()

  local editorW, editorH = FrameWidth * frameScale, FrameHeight * frameScale
  local editorX = (framesPanelWidth + lg.getWidth()) / 2 - editorW / 2

  local paletteW = palettePanel.props.squareSize * palettePanel.props.columns
  local paletteH = math.floor(#palette / palettePanel.props.columns) * palettePanel.props.squareSize

  local contentH = editorH + paletteH + paletteEditorMargin
  local contentY = lg.getHeight() / 2 - contentH / 2

  imageEditor:render(
    editorX,
    contentY,
    editorW,
    editorH)

  palettePanel:render(editorX + editorW / 2 - paletteW / 2, contentY + editorH + paletteEditorMargin, paletteW, paletteH)

  framesPanel:render(0, menuBarHeight, framesPanelWidth, love.graphics.getHeight() - menuBarHeight)

  menuBar:render(0, 0, lg.getWidth(), menuBarHeight)

  scene:finishFrame()
end
