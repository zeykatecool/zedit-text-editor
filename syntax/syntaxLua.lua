return {
    filetype = "lua",
    keywords = {
        --Its just HEX,just add 0x to beginning of number.
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
