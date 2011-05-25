local h = require 'moonlib.htmlify'
local l = require 'moonlib.list'
local tbx = require 'moonlib.tableAux'
local json = require 'json'

local pairs = pairs
local ipairs = ipairs
local type = type
local tostring = tostring

module(...)

--[[
Escape some special HTML characters in `content`, such as '<', '>', '&', and the
single and double quotes. Returns the resulting sting after the special characters are replaced
with their escape codes.

	local res = "This a &lt; b &gt; c &amp;&amp; &quot;apple&quot; = &#039;orange&#039;"
	htmlEsc("This a < b > c && \"apple\" = 'orange'") == res
]]
function htmlEsc (content)
	return content:gsub("[<>&'\"]",
		function (c)
			local r
			if c == "<" then r = "&lt;"
			elseif c == ">" then r = "&gt;"
			elseif c == "&" then r = "&amp;"
			elseif c == "'" then r = "&#039;"
			elseif c == '"' then r = "&quot;"
			end
			return r
		end)
end

--[[
Make an HTML table row from the `rowData` list argument.
Each `rowData` list item is a table data column. 'head' is an
optional boolean value; set to true for a heading row. The optional `id`
string argument gives the row an id attribute. Returns the HTML row.

	local data = {"one", "two", "three"}
	makeTR(data) == "<tr><td>one</td><td>two</td><td>three</td></tr>"
	makeTR(data, true) == "<tr><th>one</th><th>two</th><th>three</th></tr>"
	makeTR(data, false, "select") == "<tr id=\"select\"><td>one</td><td>two</td><td>three</td></tr>"
]]
function makeTR (row, head, id)
	local dt = h'td'
	if head then dt = h'th' end
	if id then id = '#'..id end
	return h'tr'[id](l.map(dt, row))
end

--[[
Create a HTML table from a table value `rows`. The table value can be a list of row
strings or a two-dimensional table representing rows/data. The optional `ctable`
argument are additional HTML attributes to add to the HTML table tag.  Reurns the HTML
table.    

	local rows = {
		{"one", "two"},
		{"three", "four"},
	}
	local HTML_table = "<table bgcolor=\"blue\"><tr><td>one</td><td>two</td></tr><tr>"..
		"<td>three</td><td>four</td></tr></table>"
	htable(rows, {bgcolor = "blue"}) == HTML_table
]]
function htable (rows, ctable)
	ctable = ctable or {}
	for i,row in ipairs(rows) do
		if type(row) == 'table' then
			ctable[i] = makeTR(row)
		else
			ctable[i] = row
		end
	end
	return h'table'(ctable)
end

--[[
Make an HTML input tag

	print(hinput('submit', nil, "Submit"))
	hinput('submit', nil, "Submit") == '<input value="Submit" type="submit"></input>'
]]
function hinput (t, name, value, ctable)
	ctable = ctable or {}
	ctable.type = t
	ctable.value = value
	ctable.name = name
	return h'input'(ctable)
end

--[[
Make a link tag with an optional `name`. If name is not given, then
the `url` will be displayed in its place. `ctable` is a table mapping additional tag attributes to values.

	href("http://moonloop.net") == "<a href=\"http://moonloop.net\">http://moonloop.net</a>"
	href("http://moonloop.net", "Moonloop") == "<a href=\"http://moonloop.net\">Moonloop</a>"
	local lastText = '<a href="http://moonloop.net" class="selected">Moonloop</a>'
	href("http://moonloop.net", "Moonloop", {class="selected"}) == lastText
]]
function href (url, name, ctable)
	ctable = ctable or {}
	ctable.href = url
	name = name or url
	ctable[1] = name
	return h'a'(ctable)
end

function itemLink (...)
	return h'li'(href(...))
end

function txtInput (id, label, maxlen)
	return h'p'{h'label'{['for']=id, label .. ':'},
		h'input'['#'..id]{name=id, type='text', maxlength=maxlen}}
end

function text (label, name, value)
		return h'label'{['for']=name, label}, hinput('text', name, value)
end

function submit (value)
		return hinput('submit', 'submit', value)
end

function ulist (title, items)
	return mklist(title, items, h'ul')
end

function olist (title, items)
	return mklist(title, items, h'ol')
end

function mklist (title, items, lfn)
	local lst = ''
	for _,v in ipairs(items) do
		lst = lst .. h'li'(tostring(v))
	end
	return title .. lfn{lst}
end

function htmlPage (title, cssLinks, jsLinks, body)
	return h'html'{h'head'{
			h'title'(title),
			l.map(function (v) return h'link'{href=v, rel='stylesheet', type='text/css'} end, cssLinks),
			l.map(function (v) return h'script'{src=v, type='text/javascript'} end, jsLinks)
		},
		body}
end

function wrap (inner)
		return h'html'{h'head'(), h'body'(inner)}
end

function metaData (d)
	return h'script'{type='application/json', json.encode(d)}
end

function import ()
		local env = getfenv(2)
		for k,v in pairs(_M) do
				env[k] = v
		end
end


