return {
    filetype = "lua",
    keywords = {
        ['"[^"]*"'] = { color = 0x6BD700 },
        ["'[^']*'"] = { color = 0x6BD700 },
        ["%}"] = { color = 0xFFD700 },
        ["%{"] = { color = 0xFFD700 },
        ["%("] = { color = 0xD6498C },
        ["%)"] = { color = 0xD6498C },
        ["%["] = { color = 0x6BD700 },
        ["%]"] = { color = 0x6BD700 },
        ["[%+%-%*/%%%^~=]"] = { color = 0xF29668 },
    }
}