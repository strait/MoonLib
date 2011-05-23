--[[
    local h = ...
]]

local list = require'moonlib.list'

local function make_tag(name, data, ident)
    -- Make id or class attributes
    if ident then
        local idents = ''
        local classes = {}
        for item in string.gmatch(ident, "%S+") do
            sc = item:sub(1,1)
            if sc == '#' then
                idents = idents .. ' id="' .. item:sub(2) .. '"'
            elseif sc == '.' then
                table.insert(classes, item:sub(2))
            else
                table.insert(classes, item:sub(1))
            end
        end
        if #classes ~= 0 then
            idents = idents .. ' class="' .. table.concat(classes, " ") .. '"'
        end
        ident = idents
    else
        ident = ""
    end
    if not data then
        return "<" .. name .. ident .. "/>"
    elseif type(data) == "table" then
        local attrs = {}
        for k,v in pairs(data) do
            if type(k) == "string" then
                local val = ''
                -- Expressing boolean attributes such as nowrap, noresize, and checked
                -- that don't have an attribute.  Designate as such with 'name = true'
                if v ~= true then val = '="' .. tostring(v) .. '"' end
                table.insert(attrs, " " .. k .. val)
            end
        end
        return
            "<" .. name .. ident .. table.concat(attrs) .. ">" .. table.concat(list.flatten(data)) ..
            "</" .. name .. ">"
    else
        return "<" .. name .. ident .. ">" .. tostring(data) .. "</" .. name .. ">"
    end      
end

--[[
    local text = "The item is 6 inches by 4 inches."
    
    h"p"[".description"](text) == '<p class="description">'..text..'</p>'
    h"div"["#description"](text) == '<div id="description">'..text..'</div>'

]]
local function htmlify(name)
    local tag = {}
    setmetatable(tag, {
            __call = function (_, data)
                    return make_tag(name, data)
                end,
            __index = function(_, ident)
                    return
                        function (data)
                            return make_tag(name, data, ident)
                        end
                end})
    return tag
end

return htmlify
