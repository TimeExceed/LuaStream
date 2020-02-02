# LuaStream

LuaStream is a [Lua](http://www.lua.org/) library which provides streaming APIs.
So, users can deal with finite/infinite sequences in a functional way,
like that in Clojure and other functional programming languages.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [LuaStream](#luastream)
    - [Stream interface](#stream-interface)
    - [Constructors](#constructors)
        - [from_list](#from_list)
        - [repeated](#repeated)
        - [range](#range)
        - [iterate](#iterate)
        - [zip](#zip)
    - [Methods](#methods)
        - [collect](#collect)
        - [last](#last)
        - [first](#first)
        - [map](#map)
        - [accumulate](#accumulate)
        - [chain](#chain)
        - [take](#take)
        - [drop](#drop)
        - [flatten](#flatten)

<!-- markdown-toc end -->

## Stream interface

A stream is a table,

1. Whose metatable is ```Stream```.
1. There is an field named by ```_stream```, which is a coroutine generating items.

Take ```from_list``` as an example:

```lua
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
```

## Constructors

### from_list

```from_list``` generates items in a list one by one.

### repeated

```repeated``` generates a same item repeatedly.

### range

```range``` generates numbers from a start value to a stop value with specified increment.

* ```range(start, stop)```: generates numbers from ```start``` (inclusive) to ```stop``` (exclusive) with default increment 1.
* ```range(start, stop, inc)```: generates numbers from ```start``` (inclusive) to ```stop``` (exclusive) with specified increment ```incr```.
    ```stop``` can be smaller than ```start``` when ```incr``` is negative.

### iterate

```iterate(init, f)``` generates an infinite stream

```
init, f(init), f(f(init)), ...
```

### zip

```zip``` accepts 0 or more streams,
and each time generates a list of values from every streams.

## Methods

### collect

```collect``` collects all items of a stream into a list.

* ```collect()``` returns a new list.
* ```collects(lst)``` appends all items into ```lst``` and returns that.

### last

```last()``` returns the last item of a stream.

### first

```first()``` returns the first item of a stream.

### map

```map``` accepts a function, and applies it to each item.
For example, the following snippet generates 2, 3 and 4.

```lua
from_list({1, 2, 3})
    :map(function(x)
        return x + 1
    end)
```

### accumulate

```accumulate``` accepts a function and its initial state.
Each time the function is applied on its current state and the current value from the stream,
and the result will be the next state.
For example, the following snippet generates 1 (0+1), 3 (1+2) and 6 (3+3).

```lua
from_list({1, 2, 3})
    :accumulate(
        0,
        function(state, value)
            return state + value
        end)
```

### chain

```chain``` chains a stream to another.

### take

```take(n)``` truncates a stream from the n-th item.

### drop

```drop(n)``` truncates the first n items from a stream.

### flatten

```flatten``` flattens all streams inside a stream.
