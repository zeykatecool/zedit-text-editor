local tween = require("modules.tween")
local Keyboard = require("modules.mainKeyboard"):new()
local Syntaxs = require("modules.syntax")
local inspect = require("modules.inspect")
local sendWarning = require("modules.sendWarning")
local sendError = require("modules.sendError")
local config = require("config.settings")
local keyConfig = require("config.keyControls")
local loadPicButton = require("modules.loadPicButton")

local sys = require("sys")
local ui = require("ui")
require("canvas")


ui.theme = "dark"

local program_config = {
  Running = true,
  MovingWindow = false,
  Status = "HomePage",
  Info = {},
  Searching = false,
  olds = {},
  onWindowClicking = false,
  canMove = false,
}


local mainWindow = ui.Window("ZEdit Text Editor", "raw", 1000, 650)
mainWindow:loadicon("images/mainIcon.ico")
mainWindow.bgcolor = config.mainWindow_BgColor
mainWindow:center()
mainWindow:show()


function mainWindow:onMouseDown(b)
  if b == "left" then
  program_config.onWindowClicking = true
  end
end
function mainWindow:onMouseUp(b)
  if b == "left" then
  program_config.onWindowClicking = false
  end
end

local topBar = ui.Picture(mainWindow,"images/topBar.png")
topBar.x, topBar.y = 0, -45
tween.new(topBar,35,{y = 0},function() end,tween.Easings.Linear):Play()
local sideBar = ui.Picture(mainWindow,"images/sideBar.png")
sideBar.x, sideBar.y = -270, 45
tween.new(sideBar,35,{x = 0},function() end,tween.Easings.Linear):Play()
local openFile = loadPicButton:load(mainWindow,"images/openFile.png","images/openFileHover.png",-270,170) --14
openFile.button:tofront()
openFile.buttonHover:tofront()
tween.new(openFile.button,35,{x = 14},function() end,tween.Easings.Linear):Play()
tween.new(openFile.buttonHover,35,{x = 14},function() end,tween.Easings.Linear):Play()
local openFolder = loadPicButton:load(mainWindow,"images/openFolder.png","images/openFolderHover.png",-270,230) --14
openFolder.button:tofront()
openFolder.buttonHover:tofront()
tween.new(openFolder.button,35,{x = 14},function() end,tween.Easings.Linear):Play()
tween.new(openFolder.buttonHover,35,{x = 14},function() end,tween.Easings.Linear):Play()
local settings = loadPicButton:load(mainWindow,"images/settings.png","images/settingsHover.png",-270,290) --14
settings.button:tofront()
settings.buttonHover:tofront()
tween.new(settings.button,35,{x = 14},function() end,tween.Easings.Linear):Play()
tween.new(settings.buttonHover,35,{x = 14},function() end,tween.Easings.Linear):Play()
program_config.canMove = true



local statusLabel = ui.Label(mainWindow,"")
statusLabel.x, statusLabel.y = 15,5
statusLabel.fontsize = config.statusLabel_FontSize or 21 and sendWarning:send("Config Warning:\nStatusLabel_FontSize is nil.")
statusLabel.bgcolor = config.statusLabel_BgColor or 0x1D1D1D and sendWarning:send("Config Warning:\nStatusLabel_BgColor is nil.")
statusLabel.fgcolor = config.statusLabel_FgColor or 0xFFFFFF and sendWarning:send("Config Warning:\nStatusLabel_FgColor is nil.")
if not config.statusLabel_Font then
  sendWarning:send("Config Warning:\nstatusLabel_Font is nil.")
end
statusLabel.font = config.statusLabel_Font or "Consolas"
statusLabel:show()
statusLabel:tofront()


local mainText = ui.Canvas(mainWindow)
mainText.bgcolor = 0x323232FF
mainText.width = 530
mainText.height = 200
if not config.mainText_Font then
  sendWarning:send("Config Warning:\nmainText_Font is nil.")
end
mainText.font = config.mainText_Font or "Consolas"
mainText.fontsize = config.mainText_FontSize or 85 and sendWarning:send("Config Warning:\nmainText_FontSize is nil.")
mainText.x = 270
mainText.y = 420
if not config.mainText_RadialGradient then
  sendWarning:send("Config Warning:\nmainText_RadialGradient is nil.")
end
local radial = mainText:RadialGradient(config.mainText_RadialGradient or {[0] = 0x606060FF, [1] = 0x00D1FFFF})
if not config.mainText_RadialRadius then
  sendWarning:send("Config Warning:\nmainText_RadialRadius is nil.")
end
radial.radius = config.mainText_RadialRadius or {300,300}
local size = mainText:measure(config.mainText_Text or "Coding,\nSimplified.")
local xpos = (mainText.width - size.width)/2
local ypos = (mainText.height - size.height)/2
function mainText:onPaint()
  self:clear(0x323232FF)
  mainText:print(config.mainText_Text or "Coding,\nSimplified.", xpos, ypos, radial)
    local minusorplus = math.random(0,1)
    if minusorplus == 0 then minusorplus = -4 else minusorplus = 4 end
    radial.center = { radial.center.x + minusorplus, radial.center.y+minusorplus }
end
function mainText:onHover(x, y)
  radial.center = { x, y }
end
mainText:show()

Keyboard:onPressed(function(key)
  if key == keyConfig.moveWindow_Key then
    if Keyboard:isPressing("LMB") then
      program_config.MovingWindow = true
    end
  end
  if key == "LMB" then
    if Keyboard:isPressing(keyConfig.moveWindow_Key) then
      program_config.MovingWindow = true
    end
  end
end)

Keyboard:onReleased(function(key)
  if key == keyConfig.moveWindow_Key then
    program_config.MovingWindow = false
    statusLabel.text = ""
  end
end)

---EDITOR-PROGRAM---
if not config.mainEditor_Font then
  sendWarning:send("Config Warning:\nmainEditor_Font is nil.")
end
if not config.mainEditor_FontSize then
  sendWarning:send("Config Warning:\nmainEditor_FontSize is nil.")
end
if not config.mainEditor_BgColor then
  sendWarning:send("Config Warning:\nmainEditor_BgColor is nil.")
end
if not config.rightPanel_BgColor then
  sendWarning:send("Config Warning:\nrightPanel_BgColor is nil.")
end
if not config.fileList_Font then
  sendWarning:send("Config Warning:\nfileList_Font is nil.")
end
if not config.fileList_FontSize then
  sendWarning:send("Config Warning:\nfileList_FontSize is nil.")
end

local SyntaxEdit = Object(ui.Edit)
function SyntaxEdit:constructor(...)
  function SyntaxEdit:onChange()
    if program_config.Status == "Editor" then
      program_config.Info.EditorText = self.text
    end
    self.selection.visible = false
    local from = self.selection.from
    local to = self.selection.to
    
    self.selection.from = 1
    self.selection.to = 0
    self.selection.fgcolor = 0xFFFFFF
    
    local text = self.text:gsub("\r\n", "\n")
    if not self.keywords then
      self.keywords = {}
    end
   for k,v in pairs(self.keywords) do
    local start = 1
    while start < string.len(text) do
      local s, e = text:find(k, start)
      if s ~= nil then
        local word = text:sub(s, e)
        start = e+1
        self.selection.from = s
        self.selection.to = start
        self.selection.fgcolor = v.color
      else
        break;
      end
    end
   end
    self.selection.from = from
    self.selection.to = to
    self.selection.visible = true
  end
  super(self).constructor(self, ...)
  self.rtf = true
end

local function openEDITOR(fileordir)
  if type(fileordir) == "File" then
    program_config.Status = "Editor"
    local file = fileordir
    local extension = file.extension
    for entry in each(sys.Directory("syntax"):list("*.*")) do
      if type(entry) == "File" then
        local check = require("syntax."..entry.name:gsub(".lua",""))
        if "."..check.filetype == extension then
          SyntaxEdit.keywords = check.keywords
        end
      end
    end
    local rightPanel = program_config.olds.rightPanel or ui.Panel(mainWindow)
    rightPanel.bgcolor = config.rightPanel_BgColor
    rightPanel.width = 230
    rightPanel.height = 605
    rightPanel.x, rightPanel.y = 0,45
    rightPanel.border = false
    local fileList = program_config.olds.fileList or ui.List(rightPanel,{})
    fileList.border = false
    fileList.width = 225
    fileList.height = 600
    fileList.font = config.fileList_Font or "Consolas"
    fileList.fontsize = config.fileList_FontSize or 20
    fileList:center()
    fileList:show()
    local mainEditor = program_config.olds.mainEditor or SyntaxEdit(mainWindow,"")
    mainEditor.border = false
    mainEditor.bgcolor = config.mainEditor_BgColor or 0x3F3F3F
    mainEditor.width, mainEditor.height = 742,586
    mainEditor.x, mainEditor.y = -400,55
    tween.new(mainEditor,35,{x = 250},function() end,tween.Easings.Linear):Play()
    mainEditor.font = config.mainEditor_Font or "Consolas"
    mainEditor.fontsize = config.mainEditor_FontSize or 25
    mainEditor.text = io.open(file.path.."/"..file.name, "r"):read("*a")
    mainEditor:show()
    program_config.olds = {
      rightPanel = rightPanel,
      mainEditor = mainEditor,
      fileList = fileList,
    }
    statusLabel.text = "Editing File: "..fileordir.name
    Keyboard:onPressed(function(key)
      if program_config.Status == "Editor" then
        if key == "CTRL" then
          if Keyboard:isPressing("S") then
            io.open(file.path.."/"..file.name, "w"):write(mainEditor.text):close()
            statusLabel.text = "Saved File: "..fileordir.name
          end
        end
        if key == "S" then
          if Keyboard:isPressing("CTRL") then
            io.open(file.path.."/"..file.name, "w"):write(mainEditor.text):close()
            statusLabel.text = "Saved File: "..fileordir.name
          end
        end
      end
    end)
-----------------------------------------------------------------------------------------------

  elseif type(fileordir) == "Directory" then
    local file = fileordir
    program_config.Status = "Editor"
    local rightPanel = program_config.olds.rightPanel or ui.Panel(mainWindow)
    rightPanel.bgcolor = config.rightPanel_BgColor
    rightPanel.width = 230
    rightPanel.height = 605
    rightPanel.x, rightPanel.y = 0,45
    rightPanel.border = false
    local fileList = program_config.olds.fileList or ui.List(rightPanel,{})
    fileList.border = false
    fileList.width = 225
    fileList.height = 600
    fileList.font = config.fileList_Font or "Consolas"
    fileList.fontsize = config.fileList_FontSize or 20
    fileList:center()
    for entry in each(sys.Directory(file.path):list("*.*")) do
      if type(entry) == "File" then
        fileList:add(entry.name)
      end
    end
    fileList:show()
    function fileList:onSelect(item)
      local filename = item.text
      local f = io.open(file.path.."/"..filename, "r")
      local extension = f.extension
      for entry in each(sys.Directory("syntax"):list("*.*")) do
        if type(entry) == "File" then
          local check = require("syntax."..entry.name:gsub(".lua",""))
          if "."..check.filetype == extension then
            SyntaxEdit.keywords = check.keywords
          else
            SyntaxEdit.keywords = {}
          end
        end
      end
      if f then
        f:close()
        local mainEditor = program_config.olds.mainEditor or SyntaxEdit(mainWindow,"")
        mainEditor.border = false
        mainEditor.bgcolor = config.mainEditor_BgColor or 0x3F3F3F
        mainEditor.width, mainEditor.height = 742,586
        mainEditor.x, mainEditor.y = -400,55
        tween.new(mainEditor,35,{x = 250},function() end,tween.Easings.Linear):Play()
        mainEditor.font = config.mainEditor_Font or "Consolas"
        mainEditor.fontsize = config.mainEditor_FontSize or 25
        mainEditor.text = io.open(file.path.."/"..filename, "r"):read("*a")
        mainEditor:show()
        program_config.olds = {
          rightPanel = rightPanel,
          mainEditor = mainEditor,
          fileList = fileList,
        }
        statusLabel.text = "Editing File: "..filename
        Keyboard:onPressed(function(key)
          if program_config.Status == "Editor" then
            if key == "CTRL" then
              if Keyboard:isPressing("S") then
                io.open(file.path.."/"..filename, "w"):write(mainEditor.text):close()
                statusLabel.text = "Saved File: "..filename
              end
            end
            if key == "S" then
              if Keyboard:isPressing("CTRL") then
                io.open(file.path.."/"..filename, "w"):write(mainEditor.text):close()
                statusLabel.text = "Saved File: "..filename
              end
            end
          end
        end)
      else
        sendWarning:send("File deleted or moved:\nCan not open file: "..filename)
        item:remove()
      end
    end
  end
end

function openFile.buttonHover:onClick()
  local fileDialog = ui.opendialog("Select a File")
  if fileDialog then
    statusLabel.fgcolor = 0xFFFFFF
    statusLabel.text = "Opening File: "..fileDialog.name
    tween.new(sideBar,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(mainText,35,{y=800},function() end,tween.Easings.Linear):Play()
    tween.new(openFile.button,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(openFile.buttonHover,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(openFolder.button,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(openFolder.buttonHover,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(settings.button,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(settings.buttonHover,35,{x = -270},function() end,tween.Easings.Linear):Play()
    openEDITOR(fileDialog)
  else
    statusLabel.text = "No File Selected"
    statusLabel.fgcolor = 0xFF0000
  end
end

function openFolder.buttonHover:onClick()
  local folderDialog = ui.dirdialog("Select a Folder")
  if folderDialog then
    statusLabel.fgcolor = 0xFFFFFF
    statusLabel.text = "Opening Folder: "..folderDialog.name
    tween.new(sideBar,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(mainText,35,{y=800},function() end,tween.Easings.Linear):Play()
    tween.new(openFile.button,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(openFile.buttonHover,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(openFolder.button,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(openFolder.buttonHover,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(settings.button,35,{x = -270},function() end,tween.Easings.Linear):Play()
    tween.new(settings.buttonHover,35,{x = -270},function() end,tween.Easings.Linear):Play()
    openEDITOR(folderDialog)
  else
    statusLabel.text = "No Folder Selected"
    statusLabel.fgcolor = 0xFF0000
  end
end



function mainWindow:onClose()
  program_config.Running = false
end

local previousTime = os.clock()
while program_config.Running do
  local currentTime = os.clock()
  local deltaTime = currentTime - previousTime
  tween.UpdateAll()
  previousTime = currentTime
  ui.update()
  Keyboard:update()
  if program_config.MovingWindow then
    if program_config.onWindowClicking then
    local cursorx,cursory = Keyboard:getMousePosition()
    tween:clearAll()
    tween.new(mainWindow,0.1,{x = cursorx-mainWindow.width/2,y = cursory-mainWindow.height/2},function() end,tween.Easings.Linear):Play()
    statusLabel.fgcolor = 0xFFFFFF
    statusLabel.text = "Moving Window | "..keyConfig.moveWindow_Key.."+LMB"
    end
  end
end
