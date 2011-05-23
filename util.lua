local tbx = require'moonlib.tableAux'
local type = type
local libassert = assert
local lfs = require'lfs'
local pairs = pairs
local string = string
local error = error
local io = io

module(...)

--[[
Builds on the built-in `assert` function by requiring two values to be tested for equality.
`val1` and `val2` can evaluate to either simple values or table values. If table values, each item in
the table is compared for value equality, recursively, if need be (tables nested inside tables).
The optional `message` argument functions;; the same as the optional message string agument in the built-in
assert. 
]]
function assert (val1, val2, message)
    if type(val1) == 'table' and type(val2) == 'table' then
        libassert(tbx.deepCompare(val1, val2, true) == true, message)
    else
        libassert(val1 == val2, message)
    end
end

--[[
Returns the entire contents of file `name` as a text string.
]]
function readFile (name)
    local f = io.open(name)
    local text = f:read('*all')
    f:close()
    return text
end

--[[
Opens file `name` for writing before writing `str` to the file. Then closes the file.
]]
function writeFile (name, str)
    local of, res = io.open(name, 'w')
    of:write(str)
    of:close()
end

--[[
Binds `value` to the first argument of function `func` in a returned function.
The new function returned has one less argument than `func` passed in, as
`value` has been permanently bound such that `returned(x)` is synonymous
with `func(value, x)`.

    local simple = function (x, y) return x + y end
    local fivePlus = curry(simple, 5)

    fivePlus(10) == 15
]]
function curry (func, value)
    return function (...) return func(value, ...) end
end

--[[
Returns the directory listing for `path`.
]]
function lsdir (path)
    local res = {}
    for f in lfs.dir(path) do
        res[#res + 1] = f
    end
    return res
end

--[[
Returns true if `path` is a file.
]]
function isfile (path)
    return lfs.attributes(path, 'mode') == 'file'
end

--[[
Returns true if `path` is a directory.
]]
function isdir (path)
    return lfs.attributes(path, 'mode') == 'directory'
end

--[[
Return just the directory path name for `path`, including the trailing slash.

    local path = "/home/foo/report.txt"

    dirPath(path) == "/home/foo/"
]]
function dirPath (path)
    local l = path:reverse():find('/')
    if l then
        return path:sub(1, #path - l + 1)
    else
        return ''
    end
end

--[[
Search for `modname` in lua package `path`. Return
the full path name to the module, if found. Otherwise,
return nil.
]]
function modSearch (modname, path)
    modname = string.gsub(modname, '%.', '/')
    for c in string.gmatch(path, '[^;]+') do
        local fname = string.gsub(c, '?', modname)
        if lfs.attributes(fname) then
            return fname
        end
    end
    return nil -- not found
end

-- Used to escape "'s by toCSV
local function escapeCSV (s)
    if string.find(s, '[,"\n]') then
        s = '"' .. string.gsub(s, '"', '""') .. '"'
    end
    return s
end

--[[
Convert from table `tbl` to CSV string

    toCSV({1, 2, 3, 4}) == "1,2,3,4"
]]
function toCSV (tbl)
    local s = ""
    for _,p in pairs(tbl) do
        s = s .. "," .. escapeCSV(p)
    end
    return string.sub(s, 2)      -- remove first comma
end

--[[
Serialize a Lua object `obj` and return this loadable string representation.

    serialize(1) == 1
    serialize("hello") == "\"hello\""
    serialize({1, 2, 3}) == "{\n  [1] = 1,\n  [2] = 2,\n  [3] = 3,\n}\n"
]]
function serialize (obj)
    local res = ''
    if type(obj) == 'number' then
        res = obj
    elseif type(obj) == 'string' then
        res = string.format('%q', obj)
    elseif type(obj) == 'table' then
        res = '{\n'
        for k,v in pairs(obj) do
            res = res .. '  [' .. serialize(k) .. '] = ' .. serialize(v) .. ',\n'
        end
        res = res .. '}\n'
    else
        error('cannot serialize a ' .. type(obj))
    end
    return res
end
