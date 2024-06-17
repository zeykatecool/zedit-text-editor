local S = {}
local ui = require("ui")
local SyntaxEdit = Object(ui.Edit)
function SyntaxEdit:constructor(program_config,...)
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


function S.loadEditor(program_config,...)
  return SyntaxEdit(program_config,...)
end

return S