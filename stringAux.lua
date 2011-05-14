-- Ensure that the string library is loaded globally
if not string then string = require 'string' end

local string = string
local table = table
local type = type
local pairs = pairs
local assert = assert
local math = math
local _G = _G

module(...)

--[[
Does `self` end with `suffix`?
`suffix` can be string or a table of strings. Returns true if any string in the table
is a suffix.

	endsWith("option determines", "ines") == true
	endsWith("option determines", "e") == false
	endsWith("option determines", {"after", "wak", "es"}) == true
]]
function endsWith (self, suffix)
	if type(suffix) == 'string' then
		if self:sub(-#suffix) == suffix then return true end
	elseif type(suffix) == 'table' then
		for i=1,#suffix do
			if endsWith(self, suffix[i]) then return true end
		end
	end
	return false
end

--[[
Does `self` begin with `prefix`?
`prefix` can be string or a table of strings. Returns true if any string in the table
is a prefix.

	startsWith("option determines", "opt") == true
	startsWith("option determines", {"all", "o"}) == true
	startsWith("option determines", {"all", "nest"}) == false
]]
function startsWith (self, prefix)
	if type(prefix) == 'string' then
		if self:sub(1, #prefix) == prefix then return true end
	elseif type(prefix) == 'table' then
		for i=1,#prefix do
			if startsWith(self, prefix[i]) then return true end
		end
	end
	return false
end

--[[
Does `self` contain `substring`? `substring` can be string or a table of strings. Returns true if any string in the table
is contained.

	contains("option determines", "mine") == true
	contains("option determines", {"all", "nest"}) == false
	contains("option determines", {"all", "deter"}) == true
]]
function contains (self, substring)
	if type(substring) == 'string' then
		if self:find(substring) then return true end
	elseif type(substring) == 'table' then
		for i=1,#substring do
			if contains(self, substring[i]) then return true end
		end
	end
	return false
end

--[[
Trim all whitespace before and after `self` and return the result.

	trim("  option ") == "option"
]]
function trim (self)
	return (self:gsub('^%s*(.-)%s*$', '%1'))
end

--[[
Trim all whitespace before `self` and return the result.

	ltrim("  option ") == "option "
]]
function ltrim (self)
	return (self:gsub('^%s*(.-)', '%1'))
end

--[[
Trim all whitespace after `self` and return the result.

	rtrim("  option ") == "  option"
]]
function rtrim (self)
	return (self:gsub('(.-)%s*$', '%1'))
end

--[[
Split `self` on `pattern` and return a list of strings. `pattern` is a regular expression, defaulting to
'one or more spaces'.  If `nokeep` is set to true, then keep as list items, empty values between occurances
of `pattern`.

	local a = split('abc', '')
	local b = split('a,b,c', ',')
	local c = split('a,b,c')
	local d = split('a b c')
	local e = split(',a,b,c,', ',')
	local f = split(',a,,b,c,', ',')
	local g = split(',a,,b,c,', ',', true)

	a == {'a','b','c'}
	b == {'a','b','c'}
	c == {'a,b,c'}
	d == {'a','b','c'}
	e == {'','a','b','c',''}
	f == {'','a','','b','c',''}
	g == {'a','b','c'}
]]
function split (self, pattern, nokeep)
	local begin = 1
	local lst = {}
	if not pattern then pattern = '%s+' end
	-- If empty pattern, then each character is an element
	if pattern == '' then
		for i = 1,#self do
			lst[i] = self:sub(i, i)
		end
		return lst
	end
	while true do
		local nBegin, nEnd = self:find(pattern, begin)
		if not nBegin then
			local last = self:sub(begin)
			if last ~= '' or not nokeep then lst[#lst+1] = last end
			if #lst == 1 and lst[1] == '' then
				return {}
			else
				return lst
			end
		end
		local item = self:sub(begin, nBegin - 1)
		if item ~= '' or not nokeep then
			lst[#lst+1] = item
		end
		begin = nEnd + 1
	end
end

--[[
Wrap a string `str` into a paragraph. The wrap width in characters is `width` and defaults to 78.
`indent` is the general indent in characters and defaults to 0.
`indent1` is the indent of the first line and defaults to whatever `indent` is set to.
]]
function wrap (str, width, indent, indent1)
	width = width or 78
	indent = indent or 0
	indent1 = indent1 or indent
	assert(indent1 < width and indent < width, "the indents must be less than the line width")
	str = string.rep(" ", indent1) .. str
	-- The effective length of the content
	local cLen = width - indent
	local lstart, len = 1, #str
	while len - lstart > cLen do
		local i = lstart + cLen
		while i > lstart and str:sub(i, i) ~= " " do
			i = i - 1
		end
		local j = i
		while j > lstart and str:sub(j, j) == " " do
			j = j - 1
		end
		str = str:sub(1, j) .. "\n" .. string.rep(" ", indent) .. str:sub(i + 1, -1)
		local change = indent + (j - i) + 1
		lstart = j + change
		len = len + change
	end
	return str
end

--[[
Return the English suffix for an ordinal `number` (1st, 2nd, 3rd, 4th, ...)
]]
function ordinalSuffix (number)
	number = math.mod(number, 100)
	local d = math.mod(number, 10)
	if d == 1 and number ~= 11 then
		return "st"
	elseif d == 2 and number ~= 12 then
		return "nd"
	elseif d == 3 and number ~= 13 then
		return "rd"
	else
		return "th"
	end
end

--[[
Do string replacements in `str` for all the mappings in table `tbl`.

	local changes = {March = "April", now = "later"}
	
	mapReplace(changes, "now we meet in March") == "later we meet in April"
]]
function mapReplace (tbl, str)
	for k,v in pairs(tbl) do
		str = string.gsub(str, k, v)
	end
	return str
end

--- binds a selection of the functions to the string object
--  Return the module object
function import ()
	local exp = {
		endsWith = endsWith,
		startsWith = startsWith,
		contains = contains,
		trim = trim,
		ltrim = ltrim,
		rtrim = rtrim,
		split = split,
	}
	for k,v in pairs(exp) do
		_G.string[k] = v
	end
	-- Return the module
	return _M
end


