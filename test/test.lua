local stream = require 'stream'
local testa = require 'testa'
local table = require 'table'

local collect = {}

collect.new_list = testa.is(
    function()
        local xs = stream.from_list({1, 2})
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2')
collect.exist_list = testa.is(
    function()
        local xs = {1}
        stream.from_list({2})
            :collect(xs)
        return table.concat(xs, ' ')
    end,
    '1 2')

local last = {}

last.multiple = testa.is(
    function()
        return stream.from_list({1, 2})
            :last()
    end,
    2)
last.single = testa.is(
    function()
        return stream.from_list({1})
            :last()
    end,
    1)
last.none = testa.is(
    function()
        return stream.from_list({})
            :last()
    end,
    nil)

local first = {}

first.multiple = testa.is(
    function()
        return stream.from_list({1, 2})
            :first()
    end,
    1)
first.single = testa.is(
    function()
        return stream.from_list({1})
            :first()
    end,
    1)
first.none = testa.is(
    function()
        return stream.from_list({})
            :first()
    end,
    nil)

local map = {}

map.multiple = testa.is(
    function()
        local xs = stream.from_list({1, 2})
            :map(function(x)
                return x + 1
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '2 3')
map.none = testa.is(
    function()
        local xs = stream.from_list({})
            :map(function(x)
                return x + 1
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '')

local accumulate = {}

accumulate.multiple = testa.is(
    function()
        local xs = stream.from_list({1, 2, 3})
            :accumulate(function(last, this)
                return last + this
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 3 6')
accumulate.single = testa.is(
    function()
        local xs = stream.from_list({1})
            :accumulate(function(last, this)
                return last + this
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '1')
accumulate.none = testa.is(
    function()
        local xs = stream.from_list({})
            :accumulate(function(last, this)
                return last + this
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '')

local chain = {}

chain.one_two = testa.is(
    function()
        local xs = stream.from_list({1})
            :chain(stream.from_list({2, 3}))
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2 3')
chain.none_one = testa.is(
    function()
        local xs = stream.from_list({})
            :chain(stream.from_list({1}))
            :collect()
        return table.concat(xs, ' ')
    end,
    '1')
chain.one_none = testa.is(
    function()
        local xs = stream.from_list({2})
            :chain(stream.from_list({}))
            :collect()
        return table.concat(xs, ' ')
    end,
    '2')
chain.none_none = testa.is(
    function()
        local xs = stream.from_list({})
            :chain(stream.from_list({}))
            :collect()
        return table.concat(xs, ' ')
    end,
    '')

local take = {}

take.enough = testa.is(
    function()
        local xs = stream.from_list({1, 2, 3})
            :take(2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2')
take.shortage = testa.is(
    function()
        local xs = stream.from_list({1})
            :take(2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '1')
take.zero = testa.is(
    function()
        local xs = stream.from_list({1, 2, 3})
            :take(0)
            :collect()
        return table.concat(xs, ' ')
    end,
    '')

local drop = {}

drop.enough = testa.is(
    function()
        local xs = stream.from_list({1, 2, 3})
            :drop(1)
            :collect()
        return table.concat(xs, ' ')
    end,
    '2 3')
drop.shortage = testa.is(
    function()
        local xs = stream.from_list({1})
            :drop(2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '')
drop.zero = testa.is(
    function()
        local xs = stream.from_list({1})
            :drop(0)
            :collect()
        return table.concat(xs, ' ')
    end,
    '1')

local flatten = {}

flatten.plain = testa.is(
    function()
        local xs = stream.from_list({1, 2})
            :flatten()
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2')
flatten.nested = testa.is(
    function()
        local xs = stream.from_list({1, stream.from_list({2})})
            :flatten()
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2')
flatten.recursive = testa.is(
    function()
        local xs = stream.from_list({1, stream.from_list({2, stream.from_list({3})})})
            :flatten()
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2 3')

local from_list = {}

from_list.multiple = testa.is(
    function()
        local xs = stream.from_list({1, 2})
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 2')

from_list.none = testa.is(
    function()
        local xs = stream.from_list({})
            :collect()
        return table.concat(xs, ' ')
    end,
    '')

from_list.single = testa.is(
    function()
        local xs = stream.from_list({1})
            :collect()
        return table.concat(xs, ' ')
    end,
    '1')

local repeated = {}

repeated.take = testa.is(
    function()
        local xs = stream.repeated(1)
            :take(2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '1 1')

local range = {}

range.default_incr = testa.is(
    function()
        local xs = stream.range(0, 3)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0 1 2')
range.positive_incr = testa.is(
    function()
        local xs = stream.range(0, 3, 2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0 2')
range.zero_incr = testa.is(
    function()
        local xs = stream.range(0, 3, 0)
            :take(2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0 0')
range.negative_incr = testa.is(
    function()
        local xs = stream.range(2, -1, -1)
            :collect()
        return table.concat(xs, ' ')
    end,
    '2 1 0')

local iterate = {}

iterate.normal = testa.is(
    function()
        local xs = stream.iterate(
            0,
            function(x)
                return x + 1
            end)
            :take(2)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0 1')

local zip = {}

zip.single = testa.is(
    function()
        local xs = stream.zip(stream.repeated(0))
            :take(2)
            :map(function(x)
                return table.concat(x, ',')
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0 0')
zip.twin = testa.is(
    function()
        local xs = stream.zip(stream.repeated(0), stream.repeated(1))
            :take(2)
            :map(function(x)
                return table.concat(x, ',')
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0,1 0,1')
zip.none = testa.is(
    function()
        local xs = stream.zip()
            :take(2)
            :map(function(x)
                return table.concat(x, ',')
            end)
            :collect()
        return table.concat(xs, '-')
    end,
    '-')
zip.shortest = testa.is(
    function()
        local xs = stream.zip(stream.repeated(0), stream.range(0, 3), stream.range(0, 2))
            :map(function(x)
                return table.concat(x, ',')
            end)
            :collect()
        return table.concat(xs, ' ')
    end,
    '0,0,0 0,1,1')

local filter = {}

filter.none = testa.is(
    function()
        local xs = stream.from_list({1,2,3})
            :filter(function()
                return false
            end)
            :collect()
        return table.concat(xs, ',')
    end,
    '')

filter.all = testa.is(
    function()
        local xs = stream.from_list({1,2,3})
            :filter(function()
                return true
            end)
            :collect()
        return table.concat(xs, ',')
    end,
    '1,2,3')
filter.gt1 = testa.is(
    function()
        local xs = stream.from_list({1,2})
            :filter(function(x)
                return x > 1
            end)
            :collect()
        return table.concat(xs, ',')
    end,
    '2')

testa.main({
    -- constructors --
    from_list = from_list,
    repeated = repeated,
    range = range,
    iterate = iterate,
    zip = zip,

    -- methods --
    collect = collect,
    last = last,
    first = first,
    map = map,
    accumulate = accumulate,
    chain = chain,
    take = take,
    drop = drop,
    flatten = flatten,
    filter = filter,
})

