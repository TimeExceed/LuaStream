-- The MIT License (MIT)

-- Copyright (c) 2015 Taoda, https://github.com/TimeExceed/LuaStream

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local table = require 'table'
local io = require 'io'

local function coresume(co)
    local ok, value = coroutine.resume(co)
    if not ok then
        return true
    end
    if value == nil then
        return true
    end
    return false, value
end

local function loop(co, func)
    while true do
        local fin, value = coresume(co)
        if fin then
            break
        end
        func(value)
    end
end

local Stream = {
    __index = function(this, key, ...)
        local p = table.pack(...)
        local method = rawget(getmetatable(this), key)
        return method
    end
}

function Stream.collect(this, dest)
    if dest == nil then
        dest = {}
    end
    local co = coroutine.create(this._stream)
    loop(co, function(value)
        table.insert(dest, value)
    end)
    return dest
end

function Stream.last(this)
    local res = nil
    local co = coroutine.create(this._stream)
    loop(co, function(value)
        res = value
    end)
    return res
end

function Stream.first(this)
    local co = coroutine.create(this._stream)
    local fin, value = coresume(co)
    if fin then
        return nil
    end
    return value
end

function Stream.inspect(this, func)
    if func == nil then
        func = function(x)
            io.stderr:write('inspect ')
            io.stderr:write(x)
            io.stderr:write('\n')
        end
    end
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)
            loop(co, function(value)
                func(value)
                coroutine.yield(value)
            end)
        end
    }
    return setmetatable(res, Stream)
end

function Stream.map(this, func)
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)
            loop(co, function(value)
                coroutine.yield(func(value))
            end)
        end
    }
    return setmetatable(res, Stream)
end

function Stream.accumulate(this, func)
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)

            local fin, last = coresume(co)
            if fin then
                return nil
            end
            coroutine.yield(last)

            loop(co, function(value)
                last = func(last, value)
                coroutine.yield(last)
            end)
        end
    }
    return setmetatable(res, Stream)
end

function Stream.chain(this, another)
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)
            loop(co, function(value)
                coroutine.yield(value)
            end)
            co = coroutine.create(another._stream)
            loop(co, function(value)
                coroutine.yield(value)
            end)
        end
    }
    return setmetatable(res, Stream)
end

function Stream.take(this, n)
    assert(n >= 0, n)
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)
            for i = 1, n do
                local fin, value = coresume(co)
                if fin then
                    break
                end
                coroutine.yield(value)
            end
        end
    }
    return setmetatable(res, Stream)
end

function Stream.drop(this, n)
    assert(n >= 0, n)
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)
            for i = 1, n do
                local fin, value = coresume(co)
                if fin then
                    return nil
                end
            end
            loop(co, function(value)
                coroutine.yield(value)
            end)
        end
    }
    return setmetatable(res, Stream)
end

function Stream.flatten(this)
    local res = {
        _stream = function()
            local co = coroutine.create(this._stream)
            loop(co, function(value)
                if getmetatable(value) == Stream then
                    local substream = value:flatten()
                    local co1 = coroutine.create(substream._stream)
                    loop(co1, function(value)
                        coroutine.yield(value)
                    end)
                else
                    coroutine.yield(value)
                end
            end)
        end
    }
    return setmetatable(res, Stream)
end

local cons = {Stream = Stream}

function cons.from_list(lst)
    local res = {
        _stream = function()
            for i = 1, #lst do
                coroutine.yield(lst[i])
            end
        end
    }
    return setmetatable(res, Stream)
end

function cons.repeated(item)
    local res = {
        _stream = function()
            while true do
                coroutine.yield(item)
            end
        end
    }
    return setmetatable(res, Stream)
end

function cons.range(start, stop, incr)
    if incr == nil then
        incr = 1
    end
    local next = start + incr
    local terminate = nil
    if next > start then
        terminate = function(x)
            if x >= stop then
                return true
            else
                return false
            end
        end
    elseif next < start then
        terminate = function(x)
            if x <= stop then
                return true
            else
                return false
            end
        end
    else
        terminate = function(x)
            return false
        end
    end
    local res = {
        _stream = function()
            local i = start
            while not terminate(i) do
                coroutine.yield(i)
                i = i + incr
            end
        end
    }
    return setmetatable(res, Stream)
end

function cons.iterate(init, func)
    local res = {
        _stream = function()
            local last = init
            coroutine.yield(last)
            while true do
                last = func(last)
                coroutine.yield(last)
            end
        end
    }
    return setmetatable(res, Stream)
end

function cons.zip(...)
    local streams = table.pack(...)
    local res = {
        _stream = function()
            local coroutines = {}
            for i = 1, #streams do
                table.insert(coroutines, coroutine.create(streams[i]._stream))
            end
            while true do
                local values = {}
                for i = 1, #coroutines do
                    local fin, value = coresume(coroutines[i])
                    if fin then
                        return nil
                    end
                    table.insert(values, value)
                end
                coroutine.yield(values)
            end
        end
    }
    return setmetatable(res, Stream)
end

return cons