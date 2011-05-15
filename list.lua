local type = type
local pairs = pairs
local table = table
local unpack = unpack

module(...)

--[[
An iterator that iterates through the values in `list`.
]]
function values (list)
	local i = 0
	return function () i = i + 1; return list[i] end
end
			
--[[
Apply function `fn` to the elements of `list`, in sequence, returning the array of resulting values.

	map(function (n) return '* ' .. n end, {"one", "two"}) == {"* one", "* two"}
]]
function map (fn, list)
	local result = {}
	for i = 1,#list do
		result[i] = fn(list[i])
	end
	return result
end

--[[
Reduces the `list` by iterating through it, every time passing `fn` a cumulative value and a
new value from `list`. The value returned from `fn` becomes the new cumulative value
passed to the next iteration of calling `fn`. After all the values of `list` have been iterated through,
the return value of the final `fn` call is returned for the reduction. The optional `init` value becomes
the initial cumulative value. If nil, then then the cumulative value is the first element in `list`
and the initial new value from `list` is the second element.

	reduce(function (c, n) return c + n end, {1, 2, 3}, 0) == 6
	reduce(function (c, n) return c .. n end, {"All", "The", "Time", "Now"}) == "AllTheTimeNow"
]]
function reduce (fn, list, init)
	local result = init
	local start = 1
	if not result then
		result = list[1]
		start = 2
	end
	for i = start,#list do
		result = fn(result, list[i])
	end
	return result
end

--[[
Returns a string of the items in `list` joined together. If the optional `separator` is given,
place `separator` between each item for the new string.

	local seq = {'a', 'b', 'c', 'd', 'e', 'f'}
	join(seq) == "abcdef"
	join(seq, ' ') == "a b c d e f"
]]
function join (list, separator)
	separator = separator or ''
	return reduce(
		function (a, b) return a..separator..b end,
		slice(list, 2),
		list[1]
	)

end

--[[
Return a reversed copy of `list`.

	reverse({"a", "b", "c"}) == {"c", "b", "a"}
]]
function reverse (list)
	local result = {}
	local len = #list
	for i = #list,1,-1 do
		result[len - i + 1] = list[i]
	end
	return result
end

--[[
If any element in `list` satisfies `predicate`, return true.

	any(function (n) return n < 5 end, {4, 8, 20, 88}) == true
]]
function any (predicate, list)
	for i=1,#list do
		if predicate(list[i]) then return true end
	end
	return false
end

--[[
If all the elements in `list` satisfy `predicate`, return true.

	all(function (n) return n < 5 end, {1, 2, 4}) == true
]]
function all (predicate, list)
	for i=1,#list do
		if not predicate(list[i]) then return false end
	end
	return true
end

--[[
Returns the maximum value from `numlist`, a list of numbers. If given an empty list, will return nil.

	maximum({4,5,99,13}) == 99
]]
function maximum (numlist)
	local max
	if numlist[1] then max = numlist[1] end
	for i = 2,#numlist do
		local current = numlist[i]
		if current and current > max then max = current end
	end
	return max
end

--[[
Returns the minimum value from `numlist`, a list of numbers. If given an empty list, will return nil.

	minimum({5,4,99,13}) == 4
]]
function minimum (numlist)
	local min
	if numlist[1] then min = numlist[1] end
	for i = 2,#numlist do
		local current = numlist[i]
		if current and current < min then min = current end
	end
	return min
end

--[[
Filter the values in `list` using a `predicate` function.

	filter(function (n) return n < 5 end, {12,7,4}) == {4}
	
]]
function filter (predicate, list)
	local res = {}
	for i=1,#list do
			if predicate(list[i]) then res[#res+1] = list[i] end
	end
	return res
end

--[[
Creates a new sublist of `list` bounded by `first` and `last`.
If `first` or `last` are negative, it specifies a position from the end.
If `last` is not given, the slice includes all elements to the end of `list`.

	local seq = {'a', 'b', 'c', 'd', 'e', 'f'}

	slice(seq, 1, 3) == {'a','b','c'}
	slice(seq, 1, 1) == {'a'}
	slice(seq, 6, 6) == {'f'}
	slice(seq, 6) == {'f'}
	slice(seq, 5) == {'e','f'}
]]
function slice (list, first, last)
	local res = {}
	last = last or #list
	if first < 0 then first = #list + 1 - first end -- Negative index
	if last < 0 then last = #list + 1 - last end -- Negative index
	local c = 1
	for i = first,last do
		res[c] = list[i]
		c = c + 1
	end
	return res
end

--[[
Deletes zero or more elements of `list` starting with `start` and replaces them with
the elements in list `insValues`. `deleteCount` number of elements are taken out of the list
and returned in a new list as the second return value. The first return value is a list
of the values that weren't taken out, including the optional `insValues` replacement values.
If `deleteCount` is nil, then items are delete all the way to the end of `list`.

	local seq = {'a', 'b', 'c', 'd', 'e', 'f'}

	local ns, res = splice(seq, 3)
	ns == {'a','b'}
	res == {'c','d','e','f'}
	
	ns, res = splice(seq, 3, 2)
	ns == {'a','b','e','f'}
	res == {'c','d'}
	
	ns, res = splice(seq, 3, 2, {'one', 'two'})
	ns == {'a','b','one','two','e','f'}
	res == {'c','d'}
	
	ns, res = splice(seq, 3, 0, {'one', 'two'})
	ns == {'a','b','one','two','c','d','e','f'}
	res == {}
	
	ns, res = splice(seq, 3, nil, {'one', 'two'})
	ns == {'a','b','one','two'}
	res == {'c','d','e','f'}
]]
function splice (list, start, deleteCount, insValues)
	local sList = {}
	local ret = {}
	local ending
	insValues = insValues or {}
	if deleteCount then
		ending = start + deleteCount - 1
	else
		ending = #list
	end
	-- Keep the items up to start.
	for i = 1, start - 1 do
		sList[i] = list[i]
	end
	-- Insert the new values, if any.
	merge(sList, insValues)
	-- The deleted items to be returned.
	for i = start, ending do
		ret[#ret + 1] = list[i]
	end
	-- Keep anything left at the end.
	for i = ending + 1,#list do
		sList[#sList + 1] = list[i]
	end
	return sList, ret
end
	
--[[
Merge `source` into `target`, returning `target`.
The merge operation forms an array that contains all elements from the two arrays.
The order of items in the arrays are preserved, with items from `source` appended to `target`.
`source` remains unaltered.

	local seq = {"a", "b", "c"}
	merge({"d", "e"}, seq) == {"d", "e", "a", "b", "c"}
	merge({}, seq) == {"a", "b", "c"}
	merge(seq, {}) == {"a", "b", "c"}
	merge({"foo"}, slice(seq, 3)) == {"foo", "c"}
]]
function merge (target, source)
	for i=1,#source do
		target[#target + 1] = source[i]
	end
	return target
end

--[[
Concatenate lists or items into one new list and return this new list. Potentially reduces nesting by a level.
If a single table value is passed, then operate the item values inside instead.

	concat({1,2}, 3, {4,{5,6}}) == {1,2,3,4,{5,6}}
	concat({{1,2}, 3, {4,{5,6}}}) == {1,2,3,4,{5,6}}
]]
function concat (...)
	local r = {}
	local im = {...}
	-- Strip off the containing list
	if #im == 1 and type(im[1] == 'table') then
		r = concat(unpack(im[1]))
	else
		for i=1,#im do
			local v = im[i]
			if type(v) == 'table' then
				for j=1,#v do
					r[#r+1] = v[j]
				end
			else
				r[#r+1] = v
			end
		end
	end
	return r
end

--[[
Flatten by concatenating all items in `list`
 absolutely, returning a new array without nesting.
	
	flatten({{1,2}, 3, {4,{5,6}}}) == {1,2,3,4,5,6}
]]
function flatten (list)
	local r = {}
	for i=1,#list do
		local v = list[i]
		if type(v) == "table" then
			r = concat(r, flatten(v))
		else
			r[#r+1] = v
		end
	end
	return r
end


