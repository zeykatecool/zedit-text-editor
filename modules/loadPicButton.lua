local ldb = {}
local ui = require("ui")
function ldb:load(mainWindow,img,imghover,x,y)
    local button = ui.Picture(mainWindow,img)
    button.x, button.y = x, y
    button:show()
    local buttonHover = ui.Picture(mainWindow,imghover)
    buttonHover.x, buttonHover.y = x, y
    buttonHover:hide()
    function button:onHover()
        buttonHover:show()
        buttonHover.cursor = "hand"
    end
    function buttonHover:onLeave()
        buttonHover:hide()
        buttonHover.cursor = "arrow"
    end
    return {
        button = button,
        buttonHover = buttonHover,
    }
end



return ldb