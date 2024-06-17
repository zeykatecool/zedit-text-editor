local sw = {}

function sw:send(text)
local ui = require("ui")
require("canvas")
local audio = require("audio")

local program_config = {
    Running = true,
  }

local warnSound = audio.Sound("sound/Warning.mp3")

local mainWindow = ui.Window("Warning", "fixed", 300, 100)
mainWindow:loadicon("images/mainIcon.ico")
mainWindow:center()
mainWindow:show()
warnSound:play()

local warnPicture = ui.Picture(mainWindow,"images/warning.png")
warnPicture:center()

local warnLabel = ui.Label(mainWindow,"")
warnLabel.x = 20
warnLabel.y = 10
warnLabel.font = "Consolas"
warnLabel.bgcolor = 0x404040
warnLabel.text = text
warnLabel:show()

function mainWindow:onClose()
 program_config.Running = false
end

while program_config.Running do
    ui.update()
end
end

return sw