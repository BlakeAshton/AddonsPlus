-- This file contains a library that the addon depends on. 
-- It exports functions and classes that can be used within the addon.

local someLib = {}

function someLib.exampleFunction()
    print("This is an example function from someLib.")
end

function someLib.add(a, b)
    return a + b
end

function someLib.subtract(a, b)
    return a - b
end

return someLib