local type = type
local table = table
local pairs = pairs
local getmetatable = getmetatable

module(...)

--[[
Compare `value1` with `value2`. If they are tables, then compare their keys and fields recursively.
If `ignoreMT` is true, ignore `__eq` metamethod. Return true if all the values are equal.

    deepCompare(34, 34) == true
    deepCompare({"main1", "main2", {"sub1"}}, {"main1", "main2", {"sub1"}}) == true
    deepCompare({"main1", "main2", {"sub1"}}, {{"sub1"}, "main1", "main2"}) == false
]]
function deepCompare (value1, value2, ignoreMT)
    local ty1 = type(value1)
    local ty2 = type(value2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return value1 == value2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(value1)
    if not ignoreMT and mt and mt.__eq then return value1 == value2 end
    for k1,v1 in pairs(value1) do
        local v2 = value2[k1]
        if v2 == nil or not deepCompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(value2) do
        local v1 = value1[k2]
        if v1 == nil or not deepCompare(v1,v2) then return false end
    end
    return true
end

--[[
Try to match a value in `tbl` using a comparison function `func`. `func` should return
a true value on a successful match with a `tbl` value. Then the `tbl` key and the comparison function
return value is returned. Returns false if a match is not found with a `tbl` value.

    local key, value = findWith(function (v) if #v > 4 then return v end end, {"cat", "horse"})
    key == 2
    value == "horse"
]]
function findWith (func, tbl)
    for k,v in pairs(tbl) do
        local c = func(v)
        if c then return k,c end
    end
    return false
end

--[[
Insert `value` into table `tbl`, possibly combining the new value and old value with a function.
If `key` does not exist in `tbl`, the `value` is simply added to `tbl` under `key`. If `key` does exist,
`func` will insert into `tbl` with `tbl[key] = func(key, new_value, existing_value)`. Returns the existing value
if `key` exists in `tbl`, otherwise returns nil.

    local owns = {shoes = "Cindy"}
    local addto = function (k, v, pv) return pv .. " " .. v end

    local val = insertWith(addto, "hat", "Sam", owns)
    val == nil
    owns == {shoes = "Cindy", hat = "Sam"}

    local val = insertWith(addto, "shoes", "Sam", owns)
    val == 'Cindy'
    owns == {shoes = "Cindy Sam", hat = "Sam"}
]]
function insertWith (func, key, value, tbl)
    local pv = tbl[key]
    if pv then
        tbl[key] = func(key, value, pv)
    else
        tbl[key] = value
    end
    return pv
end

--[[
Make a deep copy of a `tbl`, recursively copying all the keys and values.
This will also set the copied table's metatable to that of the original `tbl`.
Returns the new table.
]]
function deepcopy (tbl)
    if type(tbl) ~= 'table' then return tbl end
    local mt = getmetatable(tbl)
    local res = {}
    for k,v in pairs(tbl) do
        if type(v) == 'table' then
            v = deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end

--[[
Total number of elements in `tbl`.
Note that this is distinct from `#tbl`, which is the number
of values in the array part; the value returned from `size` will always
be greater or equal to that value. The difference is the size of
the hash part.

    local sample = {"one", "two"}
    sample.age = 29
    sample.name = "George"

    size(sample) == 4
    #sample == 2
]]
function size (tbl)
    local i = 0
    for k in pairs(tbl) do i = i + 1 end
    return i
end

--[[
Invert `tbl` by switching the keys with the values.
Return the result as a new table.

    invert({color = "blue", sound = "bark"}) == {blue = "color", bark = "sound"}
]]
function invert (t)
    local inv = {}
    for k, v in pairs (t) do
        inv[v] = k
    end
    return inv
end

--[[
Sorts the keys of `tbl` into an list, then iterate on this list, returning the key
and value from `tbl`. An optional `func` is the sorting function to use.
Returns an interator function that returns each pair of the sorted table.

    local words = {the = 47, an = 22, locations = 5, hour = 8}
    local sorted = {}
    for key, value in pairsByKeys(words) do
        sorted[#sorted + 1] = key
    end

    sorted == {"an", "hour", "locations", "the"}
]]
function pairsByKeys (tbl, func)
    local a = {}
    for n in pairs(tbl) do a[#a + 1] = n end
    table.sort(a, func)
    local i = 0
    return function ()
        i = i + 1
        return a[i], tbl[a[i]]
    end
end
