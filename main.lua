local ui = require("ui")
local tween = require("modules.tween")
local Keyboard = require("modules.mainKeyboard"):new()
local inspect = require("modules.inspect")
local sys = require("sys")
local program_config = {
  Running = true,
  Status = "HomePage",
  Info = {}
}
local mainWindow = ui.Window("ZEdit Text Editor", "raw", 700, 600)
mainWindow:loadicon("images/zedit.ico")
mainWindow.bgcolor = 0x1A1717
mainWindow:show()
mainWindow:center()
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


ui.theme = "dark"



local mainTitle = ui.Label(mainWindow, "ZEdit Text Editor")
mainTitle.fontsize = 40
mainTitle:center()
mainTitle.y = mainTitle.y - 100
mainTitle:show()

local mainDesc = ui.Label(mainWindow, "Fast,modern,easy,lightweight.")
mainDesc.fgcolor = 0x807171
mainDesc.fontsize = 20
mainDesc:center()
mainDesc.y = mainDesc.y - 50
mainDesc:show()

local infoButton = ui.Label(mainWindow, "")
infoButton.fontsize = 15
infoButton:center()
infoButton.y = infoButton.y + 60
infoButton:show()
infoButton.visible = false

local openFileButtonPNG = ui.Picture(mainWindow, "images/selectFile.png")
openFileButtonPNG:center()
openFileButtonPNG.y = openFileButtonPNG.y + 15
openFileButtonPNG:show()

local openFileButtonHoverPNG = ui.Picture(mainWindow, "images/selectFileHover.png")
openFileButtonHoverPNG:center()
openFileButtonHoverPNG.y = openFileButtonHoverPNG.y + 15
openFileButtonHoverPNG:show()
openFileButtonHoverPNG.visible = false

function openFileButtonPNG:onHover()
  openFileButtonHoverPNG.visible = true
  openFileButtonHoverPNG.cursor = "hand"
end

function openFileButtonHoverPNG:onLeave()
  openFileButtonHoverPNG.visible = false
  openFileButtonHoverPNG.cursor = "arrow"
end

local rightTop = ui.Picture(mainWindow, "images/rightTopClose.png")
local rightTopHover = ui.Picture(mainWindow, "images/rightTopCloseHover.png")
rightTop.x = 657
rightTop.y = 9
rightTopHover.x = 657
rightTopHover.y = 9
rightTop:show()
rightTopHover:show()
rightTopHover.visible = false

function rightTop:onHover()
  rightTopHover.visible = true
  rightTopHover.cursor = "hand"
end

function rightTopHover:onLeave()
  rightTopHover.visible = false
  rightTop.cursor = "arrow"
end

local function openEDITOR(file)
  infoButton.visible = false
  openFileButtonHoverPNG.visible = false
  openFileButtonPNG.visible = false
  local editor = SyntaxEdit(mainWindow,"")
  editor.text= io.open(program_config.Info.Path .. "/" .. program_config.Info.File.name, "r"):read("*a")
  editor.fontsize = 20
  editor.border = false
  editor.width = 680
  editor.height = 445
  editor.x = 12
  editor.y = 129
  editor:show()

  local newTitle = ui.Label(mainWindow, "ZEdit Text Editor")
  newTitle.fontsize = 30
  newTitle.x = newTitle.x + 15
  newTitle.fgcolor = 0xDDDDDD
  newTitle:show()

  local currentFile = ui.Label(mainWindow, "Editing File: " .. file.name)
  currentFile.fontsize = 15
  currentFile.x = currentFile.x + 15
  currentFile.y = currentFile.y + 50
  currentFile.fgcolor = 0xDDDDDD
  currentFile:show()

  local currentCaret = ui.Label(mainWindow, "Caret: ")
  currentCaret.fgcolor = 0xDDDDDD
  currentCaret.fontsize = 10
  currentCaret.x = 620
  currentCaret.y = 577

  local currentLine = ui.Label(mainWindow, "Line: ")
  currentLine.fgcolor = 0xDDDDDD
  currentLine.fontsize = 10
  currentLine.x = 550
  currentLine.y = 577

  function editor:onCaret()
    currentLine.text = "Line: " .. editor.line
    currentCaret.text = "Caret: " .. editor.caret
  end

  for entry in each(sys.Directory("syntax"):list("*.*")) do
    if type(entry) == "File" then
        local syntax_require = require("syntax."..entry.name:match("(.+)%..+$"))
        local filetype = syntax_require.filetype
        local keywords = syntax_require.keywords
        local currentFileFileType = program_config.Info.File.name:match("%.(%w+)$")
        if filetype == currentFileFileType then
            editor.keywords = keywords
        else
            editor.keywords = {}
        end
    end
end

Keyboard:onPressed(function(key)
    if key == "S" then
      if Keyboard:isPressing("CTRL") then
        local f = io.open(program_config.Info.Path .. "/" .. program_config.Info.File.name, "w")
        if f then
          f:write(program_config.Info.EditorText)
          f:close()
          currentFile.text = "Editing File: " .. program_config.Info.File.name .. " ( Saved " .. os.date("%H:%M:%S") .. " )"
        else
          currentFile.text = "Cannot access file: " .. program_config.Info.File.name
        end
      end
    end
    if key == "F" then
      if Keyboard:isPressing("CTRL") then
        local searchWindow = ui.Window("Find in File", "fixed", 360, 150)
        searchWindow:loadicon("images/zedit.ico")
        searchWindow.bgcolor = 0x1A1717
        searchWindow:show()

        local searchLabel = ui.Label(searchWindow, "Search: ")
        searchLabel.fontsize = 20
        searchLabel.fgcolor = 0xDDDDDD
        searchLabel.x = 16
        searchLabel.y = 7
        searchLabel:show()

        local searchEntry = ui.Entry(searchWindow, "")
        searchEntry.fontsize = 15
        searchEntry.x = 16
        searchEntry.y = 47
        searchEntry.width = 320
        searchEntry.height = 30

        local searchButtonPNG = ui.Picture(searchWindow, "images/search.png")
        searchButtonPNG.x = 221
        searchButtonPNG.y = 101
        searchButtonPNG:show()

        local searchButtonHoverPNG = ui.Picture(searchWindow, "images/searchHover.png")
        searchButtonHoverPNG.x = 221
        searchButtonHoverPNG.y = 101
        searchButtonHoverPNG.visible = false
        searchButtonHoverPNG:show()

        function searchButtonPNG:onHover()
          searchButtonHoverPNG.visible = true
          searchButtonHoverPNG.cursor = "hand"
        end

        function searchButtonHoverPNG:onLeave()
          searchButtonHoverPNG.visible = false
          searchButtonPNG.cursor = "arrow"
        end

        local radioBoxUP = ui.Radiobutton(searchWindow, "Up")
        radioBoxUP.x = 16
        radioBoxUP.y = 100
        radioBoxUP:show()

        local radioBoxDOWN = ui.Radiobutton(searchWindow, "Down")
        radioBoxDOWN.x = 16
        radioBoxDOWN.y = 120
        radioBoxDOWN.checked = true
        radioBoxDOWN:show()

        function searchButtonHoverPNG:onClick()
          local willSearch = searchEntry.text
          if willSearch then
            if radioBoxUP.checked then
              local search = editor:searchup(willSearch)
              if search then
                searchWindow:hide()
                editor.caret = search
              end
            else
              local search = editor:searchdown(willSearch)
              if search then
                searchWindow:hide()
                editor.caret = search
              else
              end
            end
          end
        end
      end
    end
    if key == "T" then
      if Keyboard:isPressing("CTRL") then
        if program_config.Status == "Editor" then
          local currentEditorText = program_config.Info.EditorText
          local currentFileText = program_config.Info.Text
          if currentEditorText ~= currentFileText then
            local ask = ui.confirm("Do you want to save changes to file?")
            if ask == "yes" then
              local filee = io.open(program_config.Info.Path .. "/" .. program_config.Info.File.name, "w")
              if filee then
                filee:write(currentEditorText)
                filee:close()
                currentFile.text = "Editing File: " .. program_config.Info.File.name .. " ( Saved " .. os.date("%H:%M:%S") .. " )"
              end
            elseif ask == "no" then
              local fileDialog = ui.opendialog("Select File to Open")
              if fileDialog then
                program_config.Info.Path = fileDialog.path
                program_config.Info.File = fileDialog
                program_config.Info.Text = io.open(fileDialog.path .. "/" .. fileDialog.name, "r"):read("*a")
                program_config.Info.EditorText =  io.open(fileDialog.path .. "/" .. fileDialog.name, "r"):read("*a")
                currentFile.text = "Editing File: " .. program_config.Info.File.name
                editor.text = program_config.Info.EditorText
                editor.caret = 0
              else
                currentFile.text = "Cannot access file | Still Editing File: " .. program_config.Info.File.name
              end
              elseif ask == "cancel" then
              return
              end
            else

              local fileDialog = ui.opendialog("Select File to Open")
              if fileDialog then
                program_config.Info.Path = fileDialog.path
                program_config.Info.File = fileDialog
                program_config.Info.Text = io.open(fileDialog.path .. "/" .. fileDialog.name, "r"):read("*a")
                program_config.Info.EditorText =  io.open(fileDialog.path .. "/" .. fileDialog.name, "r"):read("*a")
                currentFile.text = "Editing File: " .. program_config.Info.File.name
                editor.text = program_config.Info.EditorText
                editor.caret = 0
              else
                currentFile.text = "Cannot access file | Still Editing File: " .. program_config.Info.File.name
              end
            end
            end
        end
    end
  end)
end

function openFileButtonHoverPNG:onClick()
  local file = ui.opendialog("Select File to Open")
  if file ~= nil then
    infoButton.text = "Opening File: " .. file.name
    infoButton.fgcolor = 0xFFFFFF
    infoButton:center()
    infoButton.y = infoButton.y + 60
    infoButton.visible = true
    program_config.Status = "Editor"
    program_config.Info = {
      File = file,
      Path = file.path,
      Text = io.open(file.path.."/"..file.name, "r"):read("*a"),
      EditorText =  io.open(file.path .. "/" .. file.name, "r"):read("*a")
    }
    openEDITOR(file)
  else
    infoButton.text = "No File Selected"
    infoButton.fgcolor = 0xEC1717
    infoButton:center()
    infoButton.y = infoButton.y + 60
    infoButton.visible = true
  end
end

function rightTopHover:onClick()
  if program_config.Status == "Editor" then
    local currentEditorText = program_config.Info.EditorText
    local currentFileText = program_config.Info.Text
    if currentEditorText ~= currentFileText then
      local ask = ui.confirm("Do you want to save changes to file?")
      if ask == "yes" then
        local file = io.open(program_config.Info.Path .. "/" .. program_config.Info.File.name, "w")
        if file then
          file:write(currentEditorText)
          file:close()
        end
      elseif ask == "no" then
      elseif ask == "cancel" then
        return
      end
    end
  end
  program_config.Running = false
end

function mainWindow:onClose()
  if program_config.Status == "Editor" then
    local currentEditorText = program_config.Info.EditorText
    local currentFileText = program_config.Info.Text
    if currentEditorText ~= currentFileText then
      local ask = ui.confirm("Do you want to save changes to file?")
      if ask == "yes" then
        local file = io.open(program_config.Info.Path .. "/" .. program_config.Info.File.name, "w")
        if file then
          file:write(currentEditorText)
          file:close()
        end
      elseif ask == "no" then
      elseif ask == "cancel" then
        return
      end
    end
  end
  program_config.Running = false
end

local previousTime = os.clock()
while program_config.Running do
  local currentTime = os.clock()
  local deltaTime = currentTime - previousTime
  tween.UpdateAll(deltaTime)
  previousTime = currentTime
  ui.update()
  Keyboard:update()
end
