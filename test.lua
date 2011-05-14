local stx = require'moonloop.stringAux'
local ut = require'moonloop.util'
local tbx = require'moonloop.tableAux'
local l = require'moonloop.list'

function printList (lst)
  for i=1,#lst do
    print(lst[i])
  end
end

--*** Testing string functions ***

-- stringAux.endsWith
ut.assert(
	stx.endsWith('option determines', 'ines'),
	true)

ut.assert(
	stx.endsWith('option determines', 's'),
	true)

ut.assert(
	stx.endsWith('option determines', {'after', 'wak', 'es'}),
	true)

ut.assert(
	stx.endsWith("option determines", "e"),
	false)

-- stringAux.startsWith
ut.assert(
	stx.startsWith('option determines', 'opt'),
	true)

ut.assert(
	stx.startsWith('option determines', {'all', 'o'}),
	true)

ut.assert(
	stx.startsWith('option determines', {'all', 'nest'}),
	false)

-- stringAux.contains
ut.assert(
	stx.contains('option determines', {'all', 'nest'}),
	false)

ut.assert(
	stx.contains('option determines', {'all', 'deter'}),
	true)

ut.assert(
	stx.contains('option determines', 'mine'),
	true)

-- stringAux.trim
ut.assert(
	stx.trim('  option '),
	'option')

ut.assert(
	stx.rtrim('  option '),
	'  option')

ut.assert(
	stx.ltrim('  option '),
	'option ')

-- stringAux.ordinalSuffix
ut.assert('1' .. stx.ordinalSuffix(1), '1st')
ut.assert('2' .. stx.ordinalSuffix(2), '2nd')
ut.assert('3' .. stx.ordinalSuffix(3), '3rd')
ut.assert('4' .. stx.ordinalSuffix(4), '4th')
ut.assert('11' .. stx.ordinalSuffix(11), '11th')
ut.assert('12' .. stx.ordinalSuffix(12), '12th')
ut.assert('13' .. stx.ordinalSuffix(13), '13th')
ut.assert('14' .. stx.ordinalSuffix(14), '14th')
ut.assert('21' .. stx.ordinalSuffix(21), '21st')
ut.assert('22' .. stx.ordinalSuffix(22), '22nd')
ut.assert('23' .. stx.ordinalSuffix(23), '23rd')
ut.assert('24' .. stx.ordinalSuffix(24), '24th')
  
-- stringAux.split
local a = stx.split('abc', '')
local b = stx.split('a,b,c', ',')
local c = stx.split('a,b,c')
local d = stx.split('a b c')
local e = stx.split(',a,b,c,', ',')
local f = stx.split(',a,,b,c,', ',')
local g = stx.split(',a,,b,c,', ',', true)

ut.assert(a, {'a','b','c'})
ut.assert(b, {'a','b','c'})
ut.assert(c, {'a,b,c'})
ut.assert(d, {'a','b','c'})
ut.assert(e, {'','a','b','c',''})
ut.assert(f, {'','a','','b','c',''})
ut.assert(g, {'a','b','c'})

--*** Testing list functions ***

-- list.slice

local seq = {'a', 'b', 'c', 'd', 'e', 'f'}

ut.assert(l.slice(seq, 1, 3), {'a','b','c'})
ut.assert(l.slice(seq, 1, 1), {'a'})
ut.assert(l.slice(seq, 6, 6), {'f'})
ut.assert(l.slice(seq, 6), {'f'})
ut.assert(l.slice(seq, 5), {'e','f'})

-- list.merge

ut.assert(l.merge({}, seq), seq)
ut.assert(l.merge(seq, {}), seq)
ut.assert(l.merge({'foo'}, l.slice(seq, 6)), {'foo', 'f'})

-- list.splice

local seq = {'a', 'b', 'c', 'd', 'e', 'f'}

local ns, res = l.splice(seq, 3)
ut.assert(ns, {'a','b'})
ut.assert(res, {'c','d','e','f'})

local ns, res = l.splice(seq, 3, 2)
ut.assert(ns, {'a','b','e','f'})
ut.assert(res, {'c','d'})

local ns, res = l.splice(seq, 3, 2, {'one', 'two'})
ut.assert(ns, {'a','b','one','two','e','f'})
ut.assert(res, {'c','d'})

local ns, res = l.splice(seq, 3, 0, {'one', 'two'})
ut.assert(ns, {'a','b','one','two','c','d','e','f'})
ut.assert(res, {})

local ns, res = l.splice(seq, 3, nil, {'one', 'two'})
ut.assert(ns, {'a','b','one','two'})
ut.assert(res, {'c','d','e','f'})

-- list.concat

ut.assert(l.concat({1,2}, 3, {4,{5,6}}), {1,2,3,4,{5,6}})
ut.assert(l.concat({{1,2}, 3, {4,{5,6}}}), {1,2,3,4,{5,6}})

-- list.flatten

ut.assert(l.flatten({{1,2}, 3, {4,{5,6}}}), {1,2,3,4,5,6})

-- list.join

ut.assert(l.join(seq), 'a b c d e f')
ut.assert(l.join(seq, ','), 'a,b,c,d,e,f')

print('All tests passed!!')
